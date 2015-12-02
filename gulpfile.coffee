path     = require 'path'
gulp     = require 'gulp'
plumber  = require 'gulp-plumber'
del      = require 'del'
stylus   = require 'gulp-stylus'
coffee   = require 'gulp-coffee'
pepper   = require 'gulp-pepper'
salt     = require 'gulp-salt'
jade     = require 'gulp-jade'
gutil    = require 'gulp-util'
debug    = require 'gulp-debug'
bump     = require 'gulp-bump'
source   = require 'gulp-sourcemaps'
symdest  = require 'gulp-symdest'
release  = require 'gulp-github-release'
electron = require 'gulp-atom-electron'
 
onError = (err) -> gutil.log err

gulp.task 'coffee', ->
    gulp.src ['win.coffee', 'app.coffee','coffee/**/*.coffee'], base: '.'
        .pipe plumber()
        .pipe debug title: 'coffee'
        .pipe source.init()
        .pipe pepper
            stringify: (info) -> '"'+info.class + info.type + info.method + ' ► "'
            paprika: 
                dbg: 'log'
        .pipe coffee(bare: true).on('error', onError)
        .pipe source.write('./')
        .pipe gulp.dest 'js/'
    
gulp.task 'bin', ->
    gulp.src ['bin/*.coffee'], base: '.'
        .pipe plumber()
        .pipe debug title: 'bin'
        .pipe coffee(bare: true).on('error', onError)
        .pipe gulp.dest '.'
        
gulp.task 'style', ->
    gulp.src 'style/*.styl'
        .pipe plumber()
        .pipe debug title: 'style'
        .pipe stylus()
        .pipe gulp.dest 'style'

gulp.task 'jade', ->
    gulp.src '*.jade', base: '.'
        .pipe plumber()
        .pipe debug title: 'jade'
        .pipe jade pretty: true
        .pipe gulp.dest '.'
        
gulp.task 'salt', ->
    gulp.src ['win.coffee', 'app.coffee', 'coffee/**/*.coffee', 'bin/*.coffee', 'style/*.styl'], base: '.'
        .pipe plumber()
        .pipe debug title: 'salt'
        .pipe salt()
        .pipe gulp.dest '.'

gulp.task 'bump', ->
    gulp.src('./package.json')
        .pipe bump()
        .pipe gulp.dest '.'

gulp.task 'clean', ->
    del [
        'js'
        'app'
        'win.html'
        '*.log'
        'bin/strudl.js'
        'bin/strudl.app'
        'bin/strudl.app.tgz'
        'style/*.css'
        '!style/font-awesome.css'
    ]

gulp.task 'release', ->
    gulp.src './bin/strudl.app.tgz'
        .pipe release
            #token: GITHUB_TOKEN
            repo: 'strudl'
            owner: 'monsterkodi'
            prerelease: true
            manifest: require './package.json'

gulp.task 'app', ['coffee', 'bin', 'style', 'jade'], ->
    gulp.src ['./package.json', './win.html', './js/**', './style/**', './lib/**', './node_modules/**'], base: '.'
        .pipe electron 
            version: '0.35.2'
            platform: 'darwin'
            darwinIcon: 'img/strudl.icns'
            darwinBundleDocumentTypes: [
                name: 'strudl'
                role: 'Viewer'
                ostypes: ['****']
                iconFile: 'img/file.icns'
                extensions: ['json', 'cson', 'plist', 'yml']
            ]
        .pipe symdest 'app'

gulp.task 'electron-build', -> electron.dest 'electron-build', { version: '0.35.2', platform: 'darwin' }

gulp.task 'default', ->
                
    gulp.watch ['win.coffee', 'app.coffee','coffee/**/*.coffee'], ['coffee']
    gulp.watch ['bin/*.coffee'], ['bin']
    gulp.watch 'style/*.styl', ['style']
    gulp.watch '*.jade', ['jade']
