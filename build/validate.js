(function() {
  var validate,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  validate = {
    isOptions: function(o) {
      var types, _ref;
      if (o.type == null) {
        throw new Error("type must be defined");
      }
      types = ['script', 'web', 'installed', 'anon'];
      if (_ref = o.type, __indexOf.call(types, _ref) < 0) {
        throw new Error("type must be one of " + (types.join(', ')));
      }
      return true;
    },
    isScript: function(o) {
      var _ref, _ref1, _ref2, _ref3;
      if (!(((_ref = o.login) != null ? _ref.username : void 0) || ((_ref1 = o.login) != null ? _ref1.password : void 0))) {
        throw new Error("must provide username and password");
      }
      if (!(((_ref2 = o.oauth) != null ? _ref2.id : void 0) || ((_ref3 = o.oauth) != null ? _ref3.secret : void 0))) {
        throw new Error("must provide client ID and secret");
      }
      return true;
    },
    isWebApp: function(o) {
      return validate.isOptions(o);
    },
    isInstalledApp: function(o) {
      return validate.isOptions(o);
    },
    hasUserAgent: function(o) {
      if (o.user_agent == null) {
        throw new Error("need to define a user agent");
      }
      if (o.user_agent.length === 0) {
        throw new Error("need a custom user agent");
      }
      return true;
    },
    isHTTPMethod: function(m) {
      var _ref;
      if ((_ref = m.toLowerCase()) !== "get" && _ref !== "post" && _ref !== "patch" && _ref !== "put") {
        throw new Error("must be a GET, POST, PATCH or PUT request");
      }
      return true;
    },
    hasValidAuth: function(auth) {
      if (!("access_token" in auth)) {
        throw new Error("you don't have an access token");
      }
      return true;
    },
    isProperString: function(str, msg1, msg2) {
      if (typeof str !== 'string') {
        throw new Error(msg1);
      }
      if (str.length === 0) {
        throw new Error(msg2);
      }
      return true;
    },
    isUserAgent: function(str) {
      validate.isProperString(str, "must provide a user agent", "user agent must not be empty");
      return true;
    }
  };

  module.exports = validate;

}).call(this);
