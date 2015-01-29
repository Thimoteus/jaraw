# Jaraw - just another reddit api wrapper ![dependencies](https://img.shields.io/david/Thimoteus/jaraw.svg) ![devDependencies](https://img.shields.io/david/dev/Thimoteus/jaraw.svg) [![Build Status](https://travis-ci.org/Thimoteus/jaraw.svg?branch=master)](https://travis-ci.org/Thimoteus/jaraw)

So far it only supports bots/personal scripts. Hopefully more options will come.

## Installation

`npm install jaraw`

## Usage

### As a bot/personal script

```coffee
Jaraw = require 'jaraw'

options =
  type: 'script'
  login:
    username: 'your username'
    password: 'your password'
  oauth:
    id: 'client id'
    secret: 'client secret'
  user_agent: 'custom useragent'

reddit = new Jaraw options

reddit.loginAsScript ->
  reddit.get '/api/v1/me', doStuff
```

You can add a "rate_limit" property to the `options` object that can be as low as `1000`. By default, it is `2000`.

#### Logging out

```coffee
reddit.logout -> console.log "All logged out!"
```

Note: Due to the fact that refresh tokens are not given to personal scripts, using `reddit.get` or `reddit.post` after you've logged out will log you in again.

### Anonymous usage:

```coffee
reddit = new Jaraw "custom useragent"
reddit.get('/r/all.json', doStuff)
```

### Example:

Suppose you're looking at the reddit API's section on [submitting a new link](https://www.reddit.com/dev/api#POST_api_submit).

The method is "POST", the endpoint is "/api/submit" and the oauth scope is "submit". (As of the most current version, the only way to use it is as a personal script, which uses all scopes.)

Then we can do the following, after logging in:

```coffee
params =
   api_type: 'json'
   kind: 'self'
   sr: 'test'
   text: 'THIS IS A TEST! DO NOT UPVOTE!'
   title: 'testing ... '

reddit.post '/api/submit', params
```

## Building
```bash
$ npm install
$ grunt
```

This creates `jaraw.js` in the build folder. Alternatively, you can do each of these individually:
```bash
grunt coffeelint
grunt mochaTest:tests
grunt coffee
grunt uglify
```

### Running tests

`grunt mochaTest:tests`

By default, running the above command won't run tests that actually make requests to reddit's servers.

To run those, use `grunt mochaTest:integration`. Note: this also tests `.js` files in the `build` folder, so make sure you build this before running integration tests. Also, you may need to adjust `timeout` in the gruntfile.

# LICENSE

Copyright © 2015 Thimoteus

This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the LICENSE file for more details.
