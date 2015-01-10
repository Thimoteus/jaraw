(function() {
  var Jaraw, iced, qs, request, val, __iced_k, __iced_k_noop;

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
      } else if (o.rate_limit < 2000) {
        if (o.type === "anon") {
          o.rate_limit = 2000;
        } else if (o.rate_limit < 1000) {
          o.rate_limit = 1000;
        }
      }
      this.next_call = Date.now() + o.rate_limit;
      this.options = o;
    }

    Jaraw.prototype.loginAs = function(type, cb) {
      switch (type) {
        case "script":
          return this.loginAsScript(cb);
        case "web":
          return this.loginAsWeb(cb);
        case "installed":
          return this.loginAsInstalled(cb);
        default:
          throw new Error("incorrect login type");
      }
    };

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
              parent: ___iced_passed_deferral1,
              filename: "src/jaraw.iced"
            });
            request(opts, __iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  err = arguments[0];
                  inc = arguments[1];
                  return res = arguments[2];
                };
              })(),
              lineno: 53
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
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "src/jaraw.iced",
            funcname: "Jaraw.loginAsScript"
          });
          requestToken(__iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return res = arguments[1];
              };
            })(),
            lineno: 59
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          _this.auth = parseTokenRes(res);
          return cb(_this.auth);
        };
      })(this));
    };

    Jaraw.prototype._call = function(method, endpt, opts, cb) {
      var auth, body, doCall, err, me, res, t, url, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      t = Date.now() - this.next_call;
      (function(_this) {
        return (function(__iced_k) {
          if (t < 0) {
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "src/jaraw.iced",
                funcname: "Jaraw._call"
              });
              setTimeout(__iced_deferrals.defer({
                lineno: 65
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
          if (_this.options.oauth) {
            url = "https://oauth.reddit.com";
          }
          url += endpt;
          me = _this;
          doCall = function(cb) {
            var body, err, headers, res, ___iced_passed_deferral1, __iced_deferrals, __iced_k;
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
                  parent: ___iced_passed_deferral1,
                  filename: "src/jaraw.iced"
                });
                request[method.toLowerCase()](opts, __iced_deferrals.defer({
                  assign_fn: (function() {
                    return function() {
                      err = arguments[0];
                      res = arguments[1];
                      return body = arguments[2];
                    };
                  })(),
                  lineno: 83
                }));
                __iced_deferrals._fulfill();
              });
            })(this)((function(_this) {
              return function() {
                return cb(err, res, body);
              };
            })(this));
          };
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "src/jaraw.iced",
              funcname: "Jaraw._call"
            });
            doCall(__iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  err = arguments[0];
                  res = arguments[1];
                  return body = arguments[2];
                };
              })(),
              lineno: 86
            }));
            __iced_deferrals._fulfill();
          })(function() {
            (function(__iced_k) {
              var _ref;
              if ((_ref = res.statusCode) === 401 || _ref === 403) {
                (function(__iced_k) {
                  __iced_deferrals = new iced.Deferrals(__iced_k, {
                    parent: ___iced_passed_deferral,
                    filename: "src/jaraw.iced",
                    funcname: "Jaraw._call"
                  });
                  _this.loginAs(_this.options.type, __iced_deferrals.defer({
                    assign_fn: (function() {
                      return function() {
                        return auth = arguments[0];
                      };
                    })(),
                    lineno: 89
                  }));
                  __iced_deferrals._fulfill();
                })(function() {
                  (function(__iced_k) {
                    __iced_deferrals = new iced.Deferrals(__iced_k, {
                      parent: ___iced_passed_deferral,
                      filename: "src/jaraw.iced",
                      funcname: "Jaraw._call"
                    });
                    doCall(__iced_deferrals.defer({
                      assign_fn: (function() {
                        return function() {
                          err = arguments[0];
                          res = arguments[1];
                          return body = arguments[2];
                        };
                      })(),
                      lineno: 90
                    }));
                    __iced_deferrals._fulfill();
                  })(function() {
                    return __iced_k(!err ? _this.next_call = Date.now() + _this.options.rate_limit : void 0);
                  });
                });
              } else {
                return __iced_k();
              }
            })(function() {
              return cb(err, res, body);
            });
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

}).call(this);
