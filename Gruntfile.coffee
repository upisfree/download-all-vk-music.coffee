module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      compile:
        options:
          join: true
          bare: true
        files:
          'build/server.js': [
            'src/config.coffee'
            'src/auth.coffee'
            'src/database.coffee'
            'src/index.coffee'            
          ]
    
    copy:
      html:
        expand: true
        flatten: true
        src: 'src/*.html'
        dest: 'build/'

    uglify:
      build:
        src: 'build/server.js'
        dest: 'build/server.min.js'

    watch:
      coffee:
        files: ['src/**/*.coffee']
        tasks: ['coffee', 'uglify']
      html:
        files: ['src/**/*.html']
        tasks: 'copy'
      gruntfile:
        files: 'Gruntfile.coffee'
        options:
          reload: true

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', 'watch'