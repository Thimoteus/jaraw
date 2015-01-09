(function() {
  var Jaraw, iced, qs, request, val, __iced_k, __iced_k_noop,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  iced = require('iced-runtime');
  __iced_k = __iced_k_noop = function() {};

  request = require('request');

  qs = require('querystring');

  val = require('./validate');

  Jaraw = (function() {
    function Jaraw(o) {
      if (typeof o === 'object') {
        val.isOptions(o);
        val.hasUserAgent(o);
      } else {
        val.isUserAgent(o);
        o = {
          type: "anon",
          user_agent: o
        };
      }
      switch (o.type) {
        case "script":
          val.isScript(o);
          break;
        case "web":
          val.isWebApp(o);
          break;
        case "installed":
          val.isInstalledApp(o);
      }
      if (!("rate_limit" in o)) {
        o.rate_limit = 2000;
      }
      this.next_call = Date.now() + o.rate_limit;
      this.options = o;
    }

    Jaraw.prototype.loginAsScript = function(cb) {
      var err, login, oauth, parseTokenRes, requestToken, res, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      login = this.options.login;
      oauth = this.options.oauth;
      requestToken = function(cb) {
        var body, err, inc, opts, res, ___iced_passed_deferral1, __iced_deferrals, __iced_k;
        __iced_k = __iced_k_noop;
        ___iced_passed_deferral1 = iced.findDeferral(arguments);
        body = qs.stringify({
          grant_type: "password",
          username: login.username,
          password: login.password
        });
        opts = {
          url: "https://ssl.reddit.com/api/v1/access_token?" + body,
          method: "POST",
          auth: {
            user: oauth.id,
            pass: oauth.secret
          }
        };
        (function(_this) {
          return (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral1
            });
            request(opts, __iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  err = arguments[0];
                  inc = arguments[1];
                  return res = arguments[2];
                };
              })(),
              lineno: 39
            }));
            __iced_deferrals._fulfill();
          });
        })(this)((function(_this) {
          return function() {
            return cb(err, res);
          };
        })(this));
      };
      parseTokenRes = function(res) {
        res = JSON.parse(res);
        res.expires_in = Date.now().valueOf() + 1000 * res.expires_in;
        return res;
      };
      (function(_this) {
        return (function(__iced_k) {
          if (!_this.auth) {
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                funcname: "Jaraw.loginAsScript"
              });
              requestToken(__iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    err = arguments[0];
                    return res = arguments[1];
                  };
                })(),
                lineno: 46
              }));
              __iced_deferrals._fulfill();
            })(function() {
              return __iced_k(_this.auth = parseTokenRes(res));
            });
          } else {
            return __iced_k();
          }
        });
      })(this)((function(_this) {
        return function() {
          return cb(_this.auth);
        };
      })(this));
    };

    Jaraw.prototype._call = function(method, endpt, opts, cb) {
      var doCall, err, me, res, t, url, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      t = Date.now() - this.next_call;
      (function(_this) {
        return (function(__iced_k) {
          if (t < 0) {
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                funcname: "Jaraw._call"
              });
              setTimeout(__iced_deferrals.defer({
                lineno: 52
              }), t);
              __iced_deferrals._fulfill();
            })(__iced_k);
          } else {
            return __iced_k();
          }
        });
      })(this)((function(_this) {
        return function() {
          val.isHTTPMethod(method);
          if (_this.auth) {
            val.hasValidAuth(_this.auth);
          }
          if (typeof opts === "function") {
            cb = opts;
            opts = {};
          }
          if (_this.options.type === "anon") {
            url = "https://www.reddit.com";
          }
          if (_this.auth) {
            url = "https://oauth.reddit.com";
          }
          url += endpt;
          me = _this;
          doCall = function(cb) {
            var err, headers, inc, res, ___iced_passed_deferral1, __iced_deferrals, __iced_k;
            __iced_k = __iced_k_noop;
            ___iced_passed_deferral1 = iced.findDeferral(arguments);
            opts.url = url;
            headers = {
              "User-Agent": me.options.user_agent
            };
            if (this.auth) {
              headers.Authorization = "bearer " + me.auth.access_token;
            }
            opts.headers = headers;
            (function(_this) {
              return (function(__iced_k) {
                __iced_deferrals = new iced.Deferrals(__iced_k, {
                  parent: ___iced_passed_deferral1
                });
                request[method.toLowerCase()](opts, __iced_deferrals.defer({
                  assign_fn: (function() {
                    return function() {
                      err = arguments[0];
                      inc = arguments[1];
                      return res = arguments[2];
                    };
                  })(),
                  lineno: 70
                }));
                __iced_deferrals._fulfill();
              });
            })(this)((function(_this) {
              return function() {
                return cb(err, res);
              };
            })(this));
          };
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              funcname: "Jaraw._call"
            });
            doCall(__iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  err = arguments[0];
                  return res = arguments[1];
                };
              })(),
              lineno: 73
            }));
            __iced_deferrals._fulfill();
          })(function() {
            if (!err) {
              _this.next_call = Date.now() + _this.options.rate_limit;
            }
            return cb(err, res);
          });
        };
      })(this));
    };

    Jaraw.prototype.get = function(endpt, opts, cb) {
      if (opts == null) {
        opts = {};
      }
      return this._call("get", endpt, opts, cb);
    };

    Jaraw.prototype.post = function(endpt, opts, cb) {
      if (opts == null) {
        opts = {};
      }
      return this._call("post", endpt, opts, cb);
    };

    return Jaraw;

  })();

  module.exports = Jaraw;

  val = {
    isOptions: function(o) {
      var types, _ref;
      if (o.type == null) {
        throw new Error("type must be defined");
      }
      types = ['script', 'web', 'installed', 'anon'];
      if (_ref = o.type, __indexOf.call(types, _ref) < 0) {
        throw new Error("type must be one of " + (types.join(', ')));
      }
    },
    isScript: function(o) {
      var _ref, _ref1, _ref2, _ref3;
      if (!(((_ref = o.login) != null ? _ref.username : void 0) || ((_ref1 = o.login) != null ? _ref1.password : void 0))) {
        throw new Error("must provide username and password");
      }
      if (!(((_ref2 = o.oauth) != null ? _ref2.id : void 0) || ((_ref3 = o.oauth) != null ? _ref3.secret : void 0))) {
        throw new Error("must provide client ID and secret");
      }
    },
    isWebApp: function(o) {
      return val.isOptions(o);
    },
    isInstalledApp: function(o) {
      return val.isOptions(o);
    },
    hasUserAgent: function(o) {
      if (o.user_agent == null) {
        throw new Error("need to define a user agent");
      }
      if (o.user_agent.length === 0) {
        throw new Error("need a custom user agent");
      }
    },
    isHTTPMethod: function(m) {
      var _ref;
      if ((_ref = m.toLowerCase()) !== "get" && _ref !== "post") {
        throw new Error("must be a GET or POST request");
      }
    },
    hasValidAuth: function(auth) {
      if (!("access_token" in auth)) {
        throw new Error("you don't have an access token");
      }
    },
    _isProperString: function(str, msg1, msg2) {
      if (typeof str !== 'string') {
        throw new Error(msg1);
      }
      if (str.length === 0) {
        throw new Error(msg2);
      }
    },
    isUserAgent: function(str) {
      return val._isProperString(str, "must provide a user agent", "user agent must not be empty");
    }
  };

  module.exports = val;

}).call(this);
