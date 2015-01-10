# JARAW - just another reddit api wrapper ![dependencies](https://img.shields.io/david/Thimoteus/jaraw.svg) ![devDependencies](https://img.shields.io/david/dev/Thimoteus/jaraw.svg) [![Build Status](https://travis-ci.org/Thimoteus/jaraw.svg?branch=master)](https://travis-ci.org/Thimoteus/jaraw)

So far it only supports bots/personal scripts. Hopefully more options will come.

## Installation

`npm install jaraw`

## Usage

```coffee
    Jaraw = require './src/jaraw'
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
      reddit.get('/api/v1/me', doStuff)
```

Anonymous usage:

```coffee
    reddit = new Jaraw "custom useragent"
    reddit.get('/r/all.json', doStuff)
```

You should probably `npm install` first. If you're not using it anonymously, you can add a "rate_limit" property to the `options` object that can be as low as `1000`. By default, it is `2000`.

## Building

Run `grunt` to create `jaraw.js` in the `build` folder. Alternatively, you can do each of these individually:

    grunt coffeelint
    grunt mochaTest:tests
    grunt coffee
    grunt uglify

### Running tests

`grunt mochaTest:tests`

By default, running the above command won't run tests that actually make requests to reddit's servers.

To run those, use `grunt mochaTest:integration`. Warning: You may need to adjust `timeout` in the gruntfile.

# LICENSE

Copyright © 2015 Thimoteus
This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the LICENSE file for more details
