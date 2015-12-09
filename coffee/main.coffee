###
 0000000   00000000   00000000 
000   000  000   000  000   000
000000000  00000000   00000000 
000   000  000        000      
000   000  000        000      
###

_        = require 'lodash'
fs       = require 'fs'
app      = require 'app'
sds      = require 'sds'
dialog   = require 'dialog'
Window   = require 'browser-window'
MainMenu = require './mainmenu'
DockMenu = require './dockmenu'
log      = require './tools/log'
prefs    = require './tools/prefs'

# prefs.debug = true # log prefs
require('electron-debug') showDevTools: false # open console?

###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###

class Main
    
    @app = null
    @init: -> 
        
        prefs.init "#{app.getPath('userData')}/prefs.json", 
            open: []
            recent: []
            windows: {}

        Main.app = new Main()
    
    constructor: ->

        @wins     = {}
        app.on 'ready', @onReady
        app.on 'open-file', (e,p) -> prefs.one 'open', p
        app.on 'before-quit'          , -> Main.app.beforeQuit()
        app.on 'will-quit'            , ->
        app.on 'quit'                 , -> 
        app.on 'window-all-closed'    , -> 
        app.on 'will-finish-launching', -> 

    onReady: =>
        log 'app ready'

        app.removeAllListeners 'open-file'
        app.on 'open-file', (e,p) => @loadFile p
        
        MainMenu.init @
        DockMenu.init @
        
        @loadPreferences()
        
    ###
    00000000   00000000   00000000  00000000   0000000
    000   000  000   000  000       000       000     
    00000000   0000000    0000000   000000    0000000 
    000        000   000  000       000            000
    000        000   000  00000000  000       0000000 
    ###
        
    loadPreferences: ->
        
        app.clearRecentDocuments()
        
        p = prefs.load()
                
        if p.open.length            
            for f in p.open
                @loadFile f
        else
            @showAbout()
        
    ###
    00000000  000  000      00000000
    000       000  000      000     
    000000    000  000      0000000 
    000       000  000      000     
    000       000  0000000  00000000
    ###
            
    loadFile: (p) ->
        
        if @wins[p]?
            @wins[p].focus()
            return
        
        cwd = __dirname

        w = new Window
            dir:           cwd
            preloadWindow: true
            resizable:     true
            frame:         true
            show:          true
            center:        false
        
        wd = prefs.get 'windows'
        w.setBounds wd[p] if wd[p]?
                
        w.on 'close', (event) => 
            @saveBounds()
            k = _.findKey @wins, event.sender
            @wins[k].removeAllListeners()
            delete @wins[k]
            prefs.del 'open', p

        w.filePath = p
        w.loadURL "file://#{cwd}/html/win.html"

        @wins[p] = w

        prefs.one 'open', p
        prefs.one 'recent', p
        MainMenu.init @

    openFile: =>

        p = dialog.showOpenDialog
            properties: [ 'openFile']
            filters:    [ name: 'data', extensions: sds.extensions ]
            properties: [ 'openFile', 'multiSelections' ]
            
        if p?.length?
            for f in p
                if fs.existsSync f
                    @loadFile f

    reload: (win) ->
        if win?
            p = win.filePath
            dbg p
            win.close()
            @loadFile p

    focusNextWindow: (win) ->
        log 'win', win
        allWindows = Window.getAllWindows()
        for w in allWindows
            if w == win
                log 'got w'
                i = 1 + allWindows.indexOf w
                i = 0 if i >= allWindows.length
                allWindows[i].focus()

    ###
    0000000     0000000   000   000  000   000  0000000     0000000
    000   000  000   000  000   000  0000  000  000   000  000     
    0000000    000   000  000   000  000 0 000  000   000  0000000 
    000   000  000   000  000   000  000  0000  000   000       000
    0000000     0000000    0000000   000   000  0000000    0000000 
    ###
    
    saveBounds: ->
        bounds = prefs.get 'windows'
        for k, w of @wins
            bounds[k] = w.getBounds()
        prefs.set 'windows', bounds

    ###
     0000000   0000000     0000000   000   000  000000000
    000   000  000   000  000   000  000   000     000   
    000000000  0000000    000   000  000   000     000   
    000   000  000   000  000   000  000   000     000   
    000   000  0000000     0000000    0000000      000   
    ###
    
    showAbout: =>    
        cwd = __dirname
        w = new Window
            dir:           cwd
            preloadWindow: true
            resizable:     true
            frame:         true
            show:          true
            center:        false
            width:         400
            height:        420
            
        w.loadURL "file://#{cwd}/html/about.html"
        w.on 'openFileDialog', @openFile

    ###
     0000000   000   000  000  000000000
    000   000  000   000  000     000   
    000 00 00  000   000  000     000   
    000 0000   000   000  000     000   
     00000 00   0000000   000     000   
    ###
    
    beforeQuit: ->
        app.clearRecentDocuments()
        @saveBounds()
        for k, w of @wins
            w.removeAllListeners 'close'
        
    quit: ->
        app.clearRecentDocuments()
        app.quit()

if not Main.app?
    Main.init()

module.exports = Main
