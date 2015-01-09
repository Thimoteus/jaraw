request = require 'request'
qs = require 'querystring'
val = require './validate'

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

      if "rate_limit" not of o then o.rate_limit = 2000
      @next_call = Date.now() + o.rate_limit
      @options = o

   loginAs: (type, cb) ->
      switch type
         when "script" then @loginAsScript cb
         when "web" then @loginAsWeb cb
         when "installed" then @loginAsInstalled cb
         else throw new Error "incorrect login type"

   loginAsScript: (cb) ->
      login = @options.login
      oauth = @options.oauth
      requestToken = (cb) ->
         body = qs.stringify
            grant_type: "password"
            username: login.username
            password: login.password
         opts =
            url: "https://ssl.reddit.com/api/v1/access_token?#{body}"
            method: "POST"
            auth:
               user: oauth.id
               pass: oauth.secret
         await request opts, defer err, inc, res
         cb err, res
      parseTokenRes = (res) ->
         res = JSON.parse res
         res.expires_in = Date.now().valueOf() + 1000*res.expires_in
         res
      await requestToken defer err, res
      @auth = parseTokenRes res
      cb @auth

   _call: (method, endpt, opts, cb) ->
      t = Date.now() - @next_call
      if t < 0 then await setTimeout defer(), t
      val.isHTTPMethod method
      if @auth then val.hasValidAuth @auth
      if typeof opts is "function"
         cb = opts
         opts = {}

      if @options.type is "anon" then url = "https://www.reddit.com"
      if @options.oauth then url = "https://oauth.reddit.com"
      url += endpt

      me = this
      doCall = (cb) ->
         opts.url = url
         headers =
            "User-Agent": me.options.user_agent
         if @auth then headers.Authorization = "bearer #{me.auth.access_token}"
         opts.headers = headers
         await request[method.toLowerCase()] opts, defer err, res, body
         cb err, res, body

      await doCall defer err, res, body

      if res.statusCode in [401, 403]
         await @loginAs @options.type, defer auth
         await doCall defer err, res, body
         if not err then @next_call = Date.now() + @options.rate_limit

      cb err, res, body

   get: (endpt, opts = {}, cb) -> @_call("get", endpt, opts, cb)

   post: (endpt, opts = {}, cb) -> @_call("post", endpt, opts, cb)



module.exports = Jaraw
