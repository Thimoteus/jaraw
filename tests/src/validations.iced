assert = require('chai').assert
Jaraw = require '../../src/jaraw'
val = require '../../src/validate'

describe 'val', ->

   describe '.isProperString', ->

      it 'should not accept non-strings', ->
         assert.throws -> val.isProperString 5

      it 'should not accept empty strings', ->
         assert.throws -> val.isProperString ""

      it 'should accept strings of length > 0', ->
         assert.doesNotThrow -> val.isProperString 'foo'

   describe '.isProperArray', ->

      it 'should not accept non-arrays', ->
         assert.throws -> val.isProperArray 5
         assert.throws -> val.isProperArray 'foo'
         assert.throws -> val.isProperArray {}
         assert.throws -> val.isProperArray {a: 'foo', b: 'bar'}

      it 'should not accept empty arrays', ->
         assert.throws -> val.isProperArray []

      it 'should accept arrays with elements', ->
         assert.doesNotThrow -> val.isProperArray [1..3]

   describe '.isOptions', ->

      it 'should not accept an empty object', ->
         assert.throws (-> val.isOptions {}), "type must be defined"

      it 'should accept correct types', ->
         assert.throws (-> val.isOptions type: 'foo'), "type must be one of script, web, installed, anon"

      it 'should not throw with good values', ->
         assert.doesNotThrow (-> val.isOptions type: 'anon')

   describe '.isScript', ->
      o = type: 'script'

      it 'should throw an error if `login` and `username` arent proper strings', ->
         o.login =
            username: ""
            password: ""
         assert.throws (-> val.isScript o), "must provide username and password"

      it 'should throw an error if client `id` and `secret` arent proper strings', ->
         o.login =
            username: "foo"
            password: "bar"
         o.oauth =
            id: ""
            secret: ""
         assert.throws (-> val.isScript o), "must provide client ID and secret"

   describe '.isInstalledApp', ->
      o =
         type: 'installed'
         oauth: {}

      it 'should an error if missing id, redirect_uri, or scopes', ->
         assert.throws -> val.isInstalledApp o
         o.oauth.id = "foo"
         assert.throws -> val.isInstalledApp o
         o.oauth.redirect_uri = "http://localhost"
         assert.throws -> val.isInstalledApp o
         o.oauth.scopes = ["identity"]
         assert.doesNotThrow -> val.isInstalledApp o

      it 'should throw an error with empty scopes', ->
         o.oauth =
            id: "foo"
            redirect_uri: "http://localhost"
            scopes: []
         assert.throws -> val.isInstalledApp o

   describe '.hasUserAgent', ->

      it 'should only accept objects with a `user_agent` property', ->
         assert.throws (-> val.hasUserAgent {}), "need to define a user agent"

      it 'should only accept proper strings', ->
         assert.throws (-> val.hasUserAgent user_agent: ""), "need a custom user agent"

   describe '.isHTTPMethod', ->

      it 'should not accept non-strings', ->
         assert.throws (-> val.isHTTPMethod 200)

      it 'should accept crazy capitalization', ->
         assert.doesNotThrow (-> val.isHTTPMethod "GeT")

      it 'should not accept weird methods like foo', ->
         assert.throws (-> val.isHTTPMethod "foo")

   describe '.hasValidAuth', ->

      it 'should error when object doesnt have an `access_token` property', ->
         assert.throws (-> val.hasValidAuth {})

      it 'shouldnt throw an error when object has an `access_token` property', ->
         assert.doesNotThrow (-> val.hasValidAuth access_token: 'sdkjafl')
