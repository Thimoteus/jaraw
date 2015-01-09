By default, running `grunt` does not run tests for logging in.
If you want to run login tests, you should put your login information in a `private.iced` file of the following form:
    module.exports =
      type: 'script'
      login:
        username: 'your username'
        password: 'your password'
      oauth:
        id: 'client id'
        secret: 'client secret'
      user_agent: 'custom useragent'
You may need to change `timeout` in `Gruntfile.coffee` if you get `Error: timeout of 2000ms exceeded`.

Then run `grunt mochaTests`.
