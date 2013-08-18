module.exports = (grunt) ->
  grunt.initConfig
    
    coffee:
      all:
        options:
          bare: false
        files:
          'lib/onedollar.js': 'src/onedollar.coffee'
          'lib/jquery.onedollar.js': 'src/jquery.onedollar.coffee'
 
    uglify:
      my_target:
        options:
          banner: '/* OneDollar.js ~ https://github.com/voidplus/onedollar-coffeescript */\n'
          preserveComments: false
          report: false
          mangle:
            except: ['jQuery']
        files:
          'lib/onedollar.min.js': ['lib/onedollar.js']
          'lib/jquery.onedollar.min.js': ['lib/jquery.onedollar.js']

    watch:
      files: 'src/*.coffee'
      tasks: ['coffee', 'uglify']
      options:
        livereload: true

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-uglify'

    grunt.registerTask 'default', ['watch']