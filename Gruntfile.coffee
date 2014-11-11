module.exports = (grunt) ->
  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'
    meta:
      name: '<%=pkg.name%>'
      version: '<%=pkg.version%>'
      url: '<%=pkg.repository.url%>'

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
          banner: '/* <%= meta.name %> ~ <%= meta.version %> ~ <%= meta.url %> */\n'
          preserveComments: false
          report: 'gzip'
          mangle:
            except: ['jQuery']
        files:
          'lib/onedollar.min.js': ['lib/onedollar.js']
          'lib/jquery.onedollar.min.js': ['lib/onedollar.js', 'lib/jquery.onedollar.js']

    file_info:
      library:
        src: ['lib/onedollar.js', 'lib/onedollar.min.js']
      jquery:
        src: ['lib/jquery.onedollar.js', 'lib/jquery.onedollar.min.js']

    watch:
      files: 'src/*.coffee'
      tasks: ['build']
      options:
        livereload: true

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-file-info'

    grunt.registerTask 'build', ['coffee', 'uglify', 'file_info']
    grunt.registerTask 'default', ['watch']
