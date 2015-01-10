# mocha tests --compilers iced:iced-coffee-script/register

module.exports = (grunt) ->

   grunt.loadNpmTasks 'grunt-mocha-test'
   grunt.loadNpmTasks 'grunt-coffeelint'
   grunt.loadNpmTasks 'grunt-contrib-uglify'
   grunt.loadNpmTasks 'grunt-iced-coffee'

   grunt.initConfig

      pkg: grunt.file.readJSON 'package.json'

      coffeelint:
         options:
            configFile: './coffeelint.json'
         src: ['src/*.iced']
         tests: ['tests/*.iced']

      mochaTest:
         tests:
            options:
               reporter: 'spec'
               require: 'iced-coffee-script/register'
            src: ['tests/validations.iced', 'tests/constructor.iced']

         integration:
            options:
               reporter: 'spec'
               require: 'iced-coffee-script/register'
               timeout: 3000
            src: ['tests/login.iced']

      coffee:
         glob_to_multiple:
            expand: true
            flatten: true
            cwd: 'src'
            src: ['*.iced']
            dest: 'build'
            ext: '.js'

      uglify:
         jaraw:
            files:
               [{
                  expand: true
                  cwd: 'build'
                  src: '**/*.js'
                  dest: 'build'
                  ext: '.min.js'
               }]

   grunt.registerTask 'default', ['validate', 'build']
   grunt.registerTask 'build', ['coffee', 'uglify']
   grunt.registerTask 'validate', ['coffeelint', 'mochaTest:tests']
