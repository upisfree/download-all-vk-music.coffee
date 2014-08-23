module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      compile:
        options:
          join: true
          bare: true
        files:
          'build/<%= pkg.name %>.js': [
            'src/config.coffee'
            'src/utils.coffee'
            'src/auth.coffee'
            'src/database.coffee'
            'src/download.coffee'
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
        src: 'build/<%= pkg.name %>.js'
        dest: 'build/<%= pkg.name %>.min.js'

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