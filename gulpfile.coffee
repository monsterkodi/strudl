path     = require 'path'
gulp     = require 'gulp'
plumber  = require 'gulp-plumber'
del      = require 'del'
sds      = require 'sds'
stylus   = require 'gulp-stylus'
coffee   = require 'gulp-coffee'
pepper   = require 'gulp-pepper'
salt     = require 'gulp-salt'
jade     = require 'gulp-jade'
gutil    = require 'gulp-util'
debug    = require 'gulp-debug'
bump     = require 'gulp-bump'
template = require 'gulp-template'
source   = require 'gulp-sourcemaps'
symdest  = require 'gulp-symdest'
release  = require 'gulp-github-release'
electron = require 'gulp-atom-electron'
packagej = require './package.json'
 
onError = (err) -> gutil.log err

gulp.task 'coffee', ->
    gulp.src ['coffee/**/*.coffee'], base: 'coffee'
        .pipe plumber()
        # .pipe debug title: 'coffee'
        .pipe salt()
        .pipe gulp.dest 'coffee'
        # .pipe source.init()
        .pipe pepper
            stringify: (info) -> '"'+info.class + info.type + info.method + ' ► "'
            paprika: 
                dbg: 'log'
        .pipe coffee(bare: true).on('error', onError)
        # .pipe source.write '.'
        .pipe gulp.dest 'js'

gulp.task 'coffee_release', ->
    gulp.src ['win.coffee', 'app.coffee','coffee/**/*.coffee'], base: './coffee'
        .pipe plumber()
        # .pipe debug title: 'coffee'
        .pipe pepper
            stringify: (info) -> '""'
            paprika: 
                dbg: 'log'
        .pipe coffee(bare: true).on('error', onError)
        .pipe gulp.dest 'js/'
    
gulp.task 'bin', ->
    gulp.src ['bin/*.coffee'], base: '.'
        .pipe plumber()
        # .pipe debug title: 'bin'
        .pipe coffee(bare: true).on('error', onError)
        .pipe gulp.dest '.'
        
gulp.task 'style', ->
    gulp.src 'style/*.styl', base: '.'
        .pipe plumber()
        # .pipe debug title: 'style'
        .pipe salt()
        .pipe gulp.dest '.'
        .pipe stylus()
        .pipe gulp.dest 'js'

gulp.task 'jade', ->
    gulp.src 'jade/*.jade', base: 'jade'
        .pipe plumber()
        # .pipe debug title: 'jade'
        .pipe template packagej
        .pipe jade pretty: true
        .pipe gulp.dest 'js/html'
        
gulp.task 'salt', ->
    gulp.src ['win.coffee', 'app.coffee', 'coffee/**/*.coffee', 'bin/*.coffee', 'style/*.styl'], base: '.'
        .pipe plumber()
        # .pipe debug title: 'salt'
        .pipe salt()
        .pipe gulp.dest '.'

gulp.task 'bump', ->
    gulp.src('./package.json')
        .pipe bump()
        .pipe gulp.dest '.'
        
gulp.task 'clean', (c) ->
    del [
        '!js/lib/prototype.js'
        'js/*.js'
        'js/*.map'
        'js/tools'
        'js/html'
        'js/style'
        'app'
        'win.html'
        '*.log'
        'bin/strudl.js'
        'bin/strudl.app'
        'bin/strudl.app.tgz'
        'style/*.css'
    ]
    c()

gulp.task 'publish_release', ->
    gulp.src './bin/strudl.app.tgz'
        .pipe release
            #token: GITHUB_TOKEN
            repo: 'strudl'
            owner: 'monsterkodi'
            prerelease: true
            manifest: require './package.json'

electronVersion = '0.35.4'
gulp.task 'app', ['clean', 'coffee_release', 'bin', 'style', 'jade'], ->
    gulp.src ['./package.json', './js/**/*', './node_modules/**'], base: '.'
        .pipe electron 
            version: electronVersion
            platform: 'darwin'
            darwinIcon: 'img/strudl.icns'
            darwinBundleDocumentTypes: [
                name: 'strudl'
                role: 'Viewer'
                ostypes: ['****']
                iconFile: 'img/file.icns'
                extensions: sds.extensions
            ]
        # .pipe debug title: 'app'
        .pipe symdest 'app'

gulp.task 'electron-build', -> electron.dest 'electron-build', { version: electronVersion, platform: 'darwin' }

gulp.task 'default', ->
                
    gulp.watch ['win.coffee', 'app.coffee','coffee/**/*.coffee'], ['coffee']
    gulp.watch ['bin/*.coffee'], ['bin']
    gulp.watch 'style/*.styl', ['style']
    gulp.watch 'jade/*.jade', ['jade']
