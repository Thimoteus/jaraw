assert = require('chai').assert
Jaraw = require '../build/jaraw'

describe "built", ->
   it "should be able to instantiate with anonymous use", ->
      assert.doesNotThrow -> new Jaraw "foo"

   it "should be able to instantiate with auth", ->
      assert.doesNotThrow -> new Jaraw require './private'
