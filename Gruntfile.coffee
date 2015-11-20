
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
                tasks: ['salt', 'restart']
                
            style:
                files: ['style/*.styl']
                tasks: ['stylus', 'restart']
                
            js:
                files: ['*.js']
                tasks: ['restart']
                                
        shell:
            test:
                command: 'coffee test.coffee'
            run:
                command: 'bin/strudl'
            build: 
                command: "node_modules/electron-packager/cli.js . strudl --overwrite --platform=darwin --arch=x64 --prune --version=0.35.0 --app-version=0.1.0 --app-bundle-id=net.monsterkodi.strudl --ignore=node_modules/electron-prebuild --icon=img/strudl.icns"
            open: 
                command: "open strudl-darwin-x64/strudl.app"
            kill:
                command: "killall Electron || true"

        external_daemon: 
            strudl: 
                cmd: "bin/strudl"
  
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-stylus'
    grunt.loadNpmTasks 'grunt-pepper'
    grunt.loadNpmTasks 'grunt-shell'
    grunt.loadNpmTasks 'grunt-external-daemon'

    grunt.registerTask 'test',     [ 'salt', 'shell:test' ]
    grunt.registerTask 'run',      [ 'shell:run' ]
    grunt.registerTask 'build',    [ 'salt', 'stylus', 'shell:build', 'shell:open' ]
    grunt.registerTask 'restart',  [ 'shell:kill', 'external_daemon' ]
    grunt.registerTask 'default',  [ 'watch' ]
        

 
