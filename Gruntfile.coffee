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
         options:
            reporter: 'spec'
         tests:
            options:
               require: 'iced-coffee-script/register'
            src: ['tests/validations.iced', 'tests/constructor.iced']

         integration:
            options:
               require: 'iced-coffee-script/register'
               timeout: 5000
            src: ['tests/integration.iced']

         built:
            src: ['tests/built.iced']

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
                  ext: '.js'
               }]

   grunt.registerTask 'default', ['validateSrc', 'build', 'validateBuild']
   grunt.registerTask 'build', ['coffee', 'uglify']
   grunt.registerTask 'validateSrc', ['coffeelint', 'mochaTest:tests']
   grunt.registerTask 'validateBuild', ['mochaTest:built']
