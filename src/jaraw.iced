request = require 'request'
val = require './validate'

identity = (x) -> x
map = (f, xs) -> (f x for x in xs)

class Jaraw

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

      if "rate_limit" not of o
         o.rate_limit = 2000
      else if o.rate_limit < 2000
         if o.type is "anon"
            o.rate_limit = 2000
         else if o.rate_limit < 1000
            o.rate_limit = 1000

      @next_call = Date.now() + o.rate_limit
      @options = o

   loginAs: (type, cb = identity) ->
      switch type
         when "script" then @loginAsScript cb
         when "web" then @loginAsWeb cb
         when "installed" then @loginAsInstalled cb
         else throw new Error "incorrect login type"

   loginAsScript: (cb = identity) ->
      login = @options.login
      oauth = @options.oauth
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

      parseTokenRes = (res) ->
         res = JSON.parse res
         res.expires_in = Date.now().valueOf() + 1000*res.expires_in
         res

      await requestToken defer err, res
      if res
         @auth = parseTokenRes res
      else
         console.log "Login attempt failed, trying again in 2 seconds"
         await setTimeout defer(), 2000
         await loginAsScript defer()
      cb @auth

   call: (method, endpt, params, cb) ->
      t = Date.now() - @next_call
      if t < 0 then await setTimeout defer(), t
      val.isHTTPMethod method
      if @auth then val.hasValidAuth @auth
      if typeof params is "function"
         cb = params
         params = {}

      opts =
         if method.toLowerCase() is "get"
            qs: params
         else
            form: params
      opts.url = if @options.oauth then "https://oauth.reddit.com" else "https://www.reddit.com"
      opts.url += endpt

      doCall = (callback) =>
         headers =
            "User-Agent": @options.user_agent
         if @auth then headers.Authorization = "bearer #{@auth.access_token}"
         opts.headers = headers
         await request[method.toLowerCase()] opts, defer err, res, body
         callback err, res, body

      await doCall defer err, res, body

      if res?.statusCode in [401, 403]
         await @loginAs @options.type, defer auth
         await doCall defer err, res, body
         if not err then @next_call = Date.now() + @options.rate_limit

      cb err, res, body

   get: (endpt, params = {}, cb = identity) -> @call("get", endpt, params, cb)

   post: (endpt, params = {}, cb = identity) -> @call("post", endpt, params, cb)

   getListing: (endpt, params = {}, cb = identity) ->
      simplifyListing = (x) -> map ((y) -> y.data), JSON.parse(x).data.children

      await @get endpt, params, defer err, res, bod
      cb err, res, simplifyListing bod

   pm: (recipient, subj, msg, cb = identity) ->
      if /\/u\//i.test recipient then recipient = recipient[3..]
      
      params =
         api_type: 'json'
         subject: subj
         text: msg
         to: recipient

      @post 'api/compose', params, cb

   replyTo: (dest, msg, cb = identity) ->

      params =
         api_type: 'json'
         thing_id: dest
         text: msg

      @post '/api/comment', params, cb

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
