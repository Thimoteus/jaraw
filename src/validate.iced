validate =
   # checks for the type of app
   isOptions: (o) ->
      throw new Error "type must be defined" if not o.type?
      types = ['script', 'web', 'installed', 'anon']
      throw new Error "type must be one of #{types.join ', '}" if o.type not in types
      true
   isScript: (o) ->
      # checks for username, password, client id and secret
      if not (o.login?.username or o.login?.password)
         throw new Error "must provide username and password"
      if not (o.oauth?.id or o.oauth?.secret)
         throw new Error "must provide client ID and secret"
      true
   # web apps not supported yet
   isWebApp: (o) -> validate.isOptions(o)
   # installed apps not supported yet
   isInstalledApp: (o) -> validate.isOptions(o)
   # checks if a user agent was provided. For non-anonymous usage.
   hasUserAgent: (o) ->
      throw new Error "need to define a user agent" if not o.user_agent?
      throw new Error "need a custom user agent" if o.user_agent.length is 0
      true
   # checks if a user agent was provided. For anonymous usage.
   isUserAgent: (str) ->
      validate.isProperString str, "must provide a user agent", "user agent must not be empty"
      true
   # checks if the http method exists
   isHTTPMethod: (m) ->
      if m.toLowerCase() not in ["get", "post", "patch", "put"]
         throw new Error "must be a GET, POST, PATCH or PUT request"
      true
   # checks if there's an access token
   hasValidAuth: (auth) ->
      throw new Error "you don't have an access token" if "access_token" not of auth
      true
   # checks if input is a string with length > 0
   isProperString: (str, msg1, msg2) ->
      throw new Error msg1 if typeof str isnt 'string'
      throw new Error msg2 if str.length is 0
      true

module.exports = validate
