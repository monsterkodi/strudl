
module.exports = (grunt) ->

    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        salt:
            options:
                textMarker : '#!'
                dryrun     : false
                verbose    : false
                refresh    : false
            coffee:
                files:
                    'asciiHeader' : ['*.coffee']
                    'asciiText'   : ['*.coffee']
            style: 
                options:
                    verbose     : false
                    textMarker  : '//!'
                    textPrefix  : '/*'
                    textFill    : '*  '
                    textPostfix : '*/'
                files:
                    'asciiText' : ['./style/*.styl']

        watch:
          scripts:
            files: ['*.coffee']
            tasks: ['salt']

        shell:
            test:
                command: 'coffee test.coffee'

    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-pepper'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.registerTask 'test',     [ 'salt', 'shell:test' ]
