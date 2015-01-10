###
NOTE: This test requires real login information.
You should put it in a private.iced file of the following form:
module.exports =
  type: 'script'
  login:
    username: 'your username'
    password: 'your password'
  oauth:
    id: 'client id'
    secret: 'client secret'
  user_agent: 'custom useragent'
###

Jaraw = require '../src/jaraw'
assert = require('chai').assert
options = require './private'

describe "login", ->
   reddit = new Jaraw options

   beforeEach (done) ->
      reddit.loginAsScript -> done()

   it "should return with auth properties", ->
      assert.property reddit, "auth"

   it "should have an access token", ->
      assert.deepProperty reddit, "auth.access_token"

   it "should have an expires_in property in the future", ->
      future = reddit.auth.expires_in
      now = Date.now()
      assert.operator now, "<", future

   it 'should get a new access token if the old one doesnt work', (done) ->
      reddit.auth.access_token = 'jibberjabber'
      reddit.get '/r/all', (err, res, body) ->
         throw err if err
         assert.deepPropertyNotVal reddit, 'auth.access_token', 'jibberjabber'
         done()

describe "anonymous", ->
   reddit = new Jaraw "jaraw testing"

   it "should receive a response", (done) ->
      reddit.get '/r/all.json', (err, res, body) ->
         throw err if err
         assert.property res, "statusCode"
         done()
