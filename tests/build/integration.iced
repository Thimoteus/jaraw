assert = require('chai').assert
options = require '../private'
Jaraw = require '../../build/jaraw'

describe "build", ->

   it "should be able to instantiate with auth", ->
      assert.doesNotThrow -> new Jaraw require './private'
