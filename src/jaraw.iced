# The only real dependency.
request = require 'request'
# Used for validating input.
val = require './validate'

# Useful functions.
identity = (x) -> x
map = (f, xs) -> (f x for x in xs)

class Jaraw

   # When instantiating, either provide an options object for authorized usage or a string for anonymous usage.
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

      # Sets proper rate limits according to reddit's api access terms.
      if "rate_limit" not of o
         o.rate_limit = 2000
      else if o.rate_limit < 2000
         if o.type is "anon"
            o.rate_limit = 2000
         else if o.rate_limit < 1000
            o.rate_limit = 1000

      @next_call = Date.now() + o.rate_limit
      @options = o

   # Routes login types.
   refreshAccess: (type, cb = identity) ->
      switch type
         when "script" then @loginAsScript cb
         when "web" then @refreshWebAccess()
         when "installed" then @refreshInstalledAccess()
         else throw new Error "incorrect login type"

   # Used for personal scripts, bots.
   loginAsScript: (cb = identity) ->
      # get the login info
      login = @options.login
      oauth = @options.oauth

      # Gets the access token.
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

      # Sets the expiration time.
      parseTokenRes = (res) ->
         res = JSON.parse res
         res.expires_in = Date.now().valueOf() + 1000*res.expires_in
         res

      # If the access token isn't returned, it will try again in 2 seconds.
      await requestToken defer err, res
      if res
         @auth = parseTokenRes res
      else
         console.log "Login attempt failed, trying again in 2 seconds"
         await setTimeout defer(), 2000
         await loginAsScript defer()
      cb @auth

   # Used for apps installed on a user's computer.
   #
   getInstalledAuthToken: (state) ->
      # get the oauth info
      oauth = @options.oauth
      createRandomStr = -> (Math.random()).toString(36)[2..]
      STATE = state or createRandomStr() + createRandomStr()

      # see https://github.com/reddit/reddit/wiki/OAuth2#authorization-implicit-grant-flow
      CLIENT_ID = oauth.id
      URI = oauth.redirect_uri
      SCOPES = oauth.scopes
      SCOPE_STRING = SCOPES.join ','
      url = "https://www.reddit.com/api/v1/authorize?
         client_id=#{CLIENT_ID}&
         response_type=token&
         state=#{STATE}&
         redirect_uri=#{URI}&
         scope=#{SCOPE_STRING}"
      url.split(" ").join("")

   # Main method for calling reddit API.
   call: (method, endpt, params, cb) ->
      # Checks if we're making too many requests at once and waits until enough time has passed.
      t = Date.now() - @next_call
      if t < 0 then await setTimeout defer(), t
      # Checks for a good method and authorization, if applicable.
      val.isHTTPMethod method
      if @auth then val.hasValidAuth @auth
      # If there aren't any parameters, gives the correct value to the callback.
      if typeof params is "function"
         cb = params
         params = {}

      # If it's a get request, put the parameters into the url and into the request body otherwise.
      opts =
         if method.toLowerCase() is "get"
            qs: params
         else
            form: params

      # Special oauth access if we're logged in, regular-joe access if we're not.
      opts.url = if @options.oauth then "https://oauth.reddit.com" else "https://www.reddit.com"
      opts.url += endpt

      # Sets the headers and makes the actual request.
      doCall = (callback) =>
         headers =
            "User-Agent": @options.user_agent
         if @auth then headers.Authorization = "bearer #{@auth.access_token}"
         opts.headers = headers
         await request[method.toLowerCase()] opts, defer err, res, body
         callback err, res, body

      await doCall defer err, res, body

      # If our access token has expired, we'll renew it.
      if res?.statusCode in [401, 403]
         await @refreshAccess @options.type, defer auth
         await doCall defer err, res, body
         if not err then @next_call = Date.now() + @options.rate_limit

      if err or not res or not body
         cb new Error "Could not reach the reddit servers"
      if res.statusCode isnt 200
         cb new Error "Could not reach reddit: #{res.statusCode}"

      cb null, body

   # Used for GET endpoints.
   get: (endpt, params = {}, cb = identity) -> @call("get", endpt, params, cb)

   # Used for POST endpoints.
   post: (endpt, params = {}, cb = identity) -> @call("post", endpt, params, cb)

   # Shortcut for responses that return [listings](https://www.reddit.com/dev/api#section_listings).
   getListing: (endpt, params = {}, cb = identity) ->
      simplifyListing = (x) -> map ((y) -> y.data), JSON.parse(x).data.children

      await @get endpt, params, defer err, bod
      if err then return cb err
      cb null, simplifyListing bod

   # Sends `recipient` a PM with subject `subj` and body `msg`.
   pm: (recipient, subj, msg, cb = identity) ->
      if /\/u\//i.test recipient then recipient = recipient[3..]

      params =
         api_type: 'json'
         subject: subj
         text: msg
         to: recipient

      @post 'api/compose', params, cb

   # Replies to the [fullname](https://www.reddit.com/dev/api#fullnames) of a thing with text `msg`.
   # `dest` can either be the fullname of a private message, a link, or a comment.
   replyTo: (dest, msg, cb = identity) ->

      params =
         api_type: 'json'
         thing_id: dest
         text: msg

      @post '/api/comment', params, cb

   # Destroys the access token.
   # **Warning**: If you're using this as a bot/personal script, you don't get a refresh token.
   # To get around this, jaraw will log-in again any time it detects an invalid access token.
   # Therefore, you might call `logout`, then query the reddit API for oauth-only info,
   # and still get a response.
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

module.exports = Jaraw
