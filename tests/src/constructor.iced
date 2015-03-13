assert = require('chai').assert
Jaraw = require '../../src/jaraw'

describe "constructor", ->
   types = ['script', 'web', 'installed', 'anon']

   it "should throw an error with no type defined", ->
      o = {}
      assert.throws (-> new Jaraw o), "type must be defined"

   it "should throw an error without a user agent", ->
      assert.throws (-> new Jaraw()), "must provide a user agent"

   it "should throw an error with an empty user agent", ->
      assert.throws (-> new Jaraw ""), "user agent must not be empty"


   describe "anonymous usage", ->

      it "should have a rate_limit of 2000 when used anonymously", ->
         o =
            type: 'anon'
            rate_limit: 1000
            user_agent: 'user agent'
         reddit = new Jaraw o
         assert.equal reddit.options.rate_limit, 2000

      it "should throw no error with anonymous usage", ->
         assert.doesNotThrow -> new Jaraw "user agent"

      it "should have an `options` property with `type` value `anon`", ->
         reddit = new Jaraw "user agent"
         assert.deepPropertyVal reddit, "options.type", "anon"

   describe "script login", ->

      it "should have a rate_limit of no less than 1000", ->
         o =
            type: 'script'
            login:
               username: "foo"
               password: "bar"
            oauth:
               id: "123"
               secret: "abc"
            user_agent: "user agent"
            rate_limit: 999
         reddit = new Jaraw o
         assert.equal reddit.options.rate_limit, 1000

      it "should throw an error if type is wrong", ->
         o = type: 'foo'
         assert.throws (-> new Jaraw o), "type must be one of #{types.join ", "}"

      it "should throw an error with no username or password", ->
         o =
            type: 'script'
            user_agent: 'stuff'
         assert.throws (-> new Jaraw o), "must provide username and password"

      it "should throw an error with no client id or secret", ->
         o =
            type: "script"
            login:
               username: "foo"
               password: "bar"
            user_agent: "stuff"
         assert.throws (-> new Jaraw o), "must provide client ID and secret"

      it "should throw an error if the user_agent is empty", ->
         o =
            type: 'script'
            login:
               username: "foo"
               password: "bar"
            oauth:
               id: "123"
               secret: "abc"
            user_agent: ""
         assert.throws (-> new Jaraw o), "need a custom user agent"

      it "should throw no error if options make sense", ->
         o =
            type: 'script'
            login:
               username: "foo"
               password: "bar"
            oauth:
               id: "123"
               secret: "abc"
            user_agent: "user agent"
         assert.doesNotThrow -> new Jaraw o

   describe "installed login", ->

      it "should have a rate_limit of no less than 1000", ->
         o =
            type: 'installed'
            # TODO: finish this
