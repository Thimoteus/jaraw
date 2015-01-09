# mocha tests --compilers iced:iced-coffee-script/register

module.exports = (grunt) ->

   grunt.loadNpmTasks 'grunt-mocha-test'
   grunt.loadNpmTasks 'grunt-contrib-watch'
   grunt.loadNpmTasks 'grunt-coffeelint'
   grunt.loadNpmTasks 'grunt-contrib-uglify'
   grunt.loadNpmTasks 'grunt-iced-coffee'

   grunt.initConfig

      pkg: grunt.file.readJSON 'package.json'

      coffeelint:
         options:
            configFile: '../coffeelint.json'
         src: ['src/*.iced']
         tests: ['tests/*.iced']

      mochaTest:
         tests:
            options:
               reporter: 'spec'
               require: 'iced-coffee-script/register'
            src: ['tests/constructor.iced', 'tests/validations.iced']

         integration:
            options:
               reporter: 'spec'
               require: 'iced-coffee-script/register'
               timeout: 3000
            src: ['tests/login.iced']

      coffee:
         compile:
            options:
               join: true
            files:
               'build/jaraw.js': ['src/*.iced']

      uglify:
         jaraw:
            files:
               'build/jaraw.min.js': ['build/jaraw.js']

   grunt.registerTask 'default', ['coffeelint', 'mochaTest:tests', 'coffee', 'uglify']
