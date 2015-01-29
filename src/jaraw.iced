# The only real dependency
request = require 'request'
# used for validating input
val = require './validate'

# Useful functions
identity = (x) -> x
map = (f, xs) -> (f x for x in xs)

# the real deal
class Jaraw

   # when instantiating, either provide an options object for authorized usage or a string for anonymous usage.
   constructor: (o) ->
      if typeof o is 'object'
         val.isOptions o
         val.hasUserAgent o
      else
         val.isUserAgent o
         o =
            type: "anon"
            user_agent: o

      switch o.type
         when "script" then val.isScript(o)
         when "web" then val.isWebApp(o)
         when "installed" then val.isInstalledApp(o)

      # sets proper rate limits according to reddit's api access terms
      if "rate_limit" not of o
         o.rate_limit = 2000
      else if o.rate_limit < 2000
         if o.type is "anon"
            o.rate_limit = 2000
         else if o.rate_limit < 1000
            o.rate_limit = 1000

      @next_call = Date.now() + o.rate_limit
      @options = o

   # routes login types
   loginAs: (type, cb = identity) ->
      switch type
         when "script" then @loginAsScript cb
         when "web" then @loginAsWeb cb
         when "installed" then @loginAsInstalled cb
         else throw new Error "incorrect login type"

   # used for personal scripts, bots
   loginAsScript: (cb = identity) ->
      # get the login info
      login = @options.login
      oauth = @options.oauth

      # gets the access token
      requestToken = (callback) ->
         opts =
            url: "https://ssl.reddit.com/api/v1/access_token"
            method: "POST"
            form:
               grant_type: 'password'
               username: login.username
               password: login.password
            auth:
               user: oauth.id
               pass: oauth.secret
         await request opts, defer err, inc, res
         callback err, res

      # sets the expiration time
      parseTokenRes = (res) ->
         res = JSON.parse res
         res.expires_in = Date.now().valueOf() + 1000*res.expires_in
         res

      # if the access token isn't returned, it will try again in 2 seconds
      await requestToken defer err, res
      if res
         @auth = parseTokenRes res
      else
         console.log "Login attempt failed, trying again in 2 seconds"
         await setTimeout defer(), 2000
         await loginAsScript defer()
      cb @auth

   # main method for calling reddit API
   call: (method, endpt, params, cb) ->
      # checks if we're making too many requests at once and waits until enough time has passed
      t = Date.now() - @next_call
      if t < 0 then await setTimeout defer(), t
      # checks for a good method and authorization, if applicable
      val.isHTTPMethod method
      if @auth then val.hasValidAuth @auth
      # if there aren't any parameters, gives the correct value to the callback
      if typeof params is "function"
         cb = params
         params = {}

      # if it's a get request, put the parameters into the url and into the request body otherwise
      opts =
         if method.toLowerCase() is "get"
            qs: params
         else
            form: params

      # special oauth access if we're logged in, regular-joe access if we're not
      opts.url = if @options.oauth then "https://oauth.reddit.com" else "https://www.reddit.com"
      opts.url += endpt

      # sets the headers and makes the actual request
      doCall = (callback) =>
         headers =
            "User-Agent": @options.user_agent
         if @auth then headers.Authorization = "bearer #{@auth.access_token}"
         opts.headers = headers
         await request[method.toLowerCase()] opts, defer err, res, body
         callback err, res, body

      await doCall defer err, res, body

      # if our access token has expired, we'll renew it
      if res?.statusCode in [401, 403]
         await @loginAs @options.type, defer auth
         await doCall defer err, res, body
         if not err then @next_call = Date.now() + @options.rate_limit

      cb err, res, body

   # used for GET endpoints
   get: (endpt, params = {}, cb = identity) -> @call("get", endpt, params, cb)

   # used for POST endpoints
   post: (endpt, params = {}, cb = identity) -> @call("post", endpt, params, cb)

   # shortcut for responses that return [listings](https://www.reddit.com/dev/api#section_listings)
   getListing: (endpt, params = {}, cb = identity) ->
      simplifyListing = (x) -> map ((y) -> y.data), JSON.parse(x).data.children

      await @get endpt, params, defer err, res, bod
      cb err, res, simplifyListing bod

   # sends `recipient` a PM with subject `subj` and body `msg`
   pm: (recipient, subj, msg, cb = identity) ->
      if /\/u\//i.test recipient then recipient = recipient[3..]
      
      params =
         api_type: 'json'
         subject: subj
         text: msg
         to: recipient

      @post 'api/compose', params, cb

   # replies to the [fullname](https://www.reddit.com/dev/api#fullnames) of a thing with text `msg`. `dest` can either be the fullname of a private message, a link, or a comment.
   replyTo: (dest, msg, cb = identity) ->

      params =
         api_type: 'json'
         thing_id: dest
         text: msg

      @post '/api/comment', params, cb

   # destroys the access token
   logout: (cb = identity) ->
      opts =
         url: "https://ssl.reddit.com/api/v1/revoke_token"
         method: "POST"
         auth:
            user: @options.oauth.id
            pass: @options.oauth.secret
         form:
            token: @auth.access_token
            token_type_hint: "access_token"
      await request opts, defer err, res, inc
      console.log "Logged out!"
      cb err, res, inc

# the real deal
module.exports = Jaraw
