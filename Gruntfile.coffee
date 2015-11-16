
module.exports = (grunt) ->

    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        salt:
            options:
                textMarker : '#!!'
                dryrun     : false
                verbose    : false
                refresh    : false
            coffee:
                files:
                    'asciiHeader' : ['coffee/*.coffee']
                    'asciiText'   : ['coffee/*.coffee']
            style: 
                options:
                    verbose     : false
                    textMarker  : '//!'
                    textPrefix  : '/*'
                    textFill    : '*  '
                    textPostfix : '*/'
                files:
                    'asciiText' : ['./style/*.styl']

        stylus:
            compile:
                options:
                    compress: false
                files:
                    "style/fixed.css":  "style/fixed.styl"
                    "style/dark.css":   "style/dark.styl"
                    "style/bright.css": "style/bright.styl"

        watch:
            coffee:
                files: ['coffee/*.coffee']
                tasks: ['salt']
            style:
                files: ['style/*.styl']
                tasks: ['stylus']

        shell:
            test:
                command: 'coffee test.coffee'
            run:
                command: 'electron .'
            build: 
                command: "node_modules/electron-packager/cli.js . model --overwrite --platform=darwin --arch=x64 --prune --version=0.34.3 --app-version=0.1.0 --app-bundle-id=net.monsterkodi.model --ignore=node_modules/electron-prebuild --icon=img/model.icns"
            open: 
                command: "open model-darwin-x64/model.app"

    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-stylus'
    grunt.loadNpmTasks 'grunt-pepper'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.registerTask 'test',     [ 'salt', 'shell:test' ]
    grunt.registerTask 'run',      [ 'shell:run' ]
    grunt.registerTask 'build',    [ 'salt', 'stylus', 'shell:build', 'shell:open' ]
