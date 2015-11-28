###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###

_        = require 'lodash'
fs       = require 'fs'
app      = require 'app'
dialog   = require 'dialog'
Window   = require 'browser-window'
MainMenu = require './mainmenu'
DockMenu = require './dockmenu'
log      = require './tools/log'
prefs    = require './tools/prefs'

class Main
    
    @app = null
    @init: -> Main.app = new Main()
    
    constructor: ->

        @wins     = {}
        app.on 'ready', @onReady
        app.on 'open-file', (e,p) -> prefs.one 'open', p
        app.on 'before-quit'          , -> Main.app.beforeQuit()
        app.on 'will-quit'            , -> log 'on will-quit'
        app.on 'quit'                 , -> log 'on quit'
        app.on 'window-all-closed'    , -> log 'on window-all-closed'
        app.on 'will-finish-launching', -> 

    onReady: =>
        log 'app ready'

        app.removeAllListeners 'open-file'
        app.on 'open-file', (e,p) => @loadFile p
        
        MainMenu.init @
        DockMenu.init @
        
    ###
    00000000   00000000   00000000  00000000   0000000
    000   000  000   000  000       000       000     
    00000000   0000000    0000000   000000    0000000 
    000        000   000  000       000            000
    000        000   000  00000000  000       0000000 
    ###
        
    loadPreferences: ->
        
        p = prefs.load()

        for f in  p.recent
            app.addRecentDocument f
                    
        for f in p.open
            @loadFile f
        
        # app.clearRecentDocuments()
            
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
            log 'on window close'
            @saveBounds()
            k = _.findKey @wins, event.sender
            @wins[k].removeAllListeners()
            delete @wins[k]
            prefs.del 'open', p

        w.filePath = p
        w.loadURL "file://#{cwd}/../../win.html"

        @wins[p] = w

        prefs.one 'open', p
        prefs.one 'recent', p

    openFile: ->

        p = dialog.showOpenDialog
            properties: [ 'openFile']
            filters:    [ name: 'data', extensions: ['json', 'cson', 'plist'] ]
            properties: [ 'openFile', 'multiSelections' ]
            
        if p?.length?
            for f in p
                if fs.existsSync f
                    @loadFile f

    ###
    0000000     0000000   000   000  000   000  0000000     0000000
    000   000  000   000  000   000  0000  000  000   000  000     
    0000000    000   000  000   000  000 0 000  000   000  0000000 
    000   000  000   000  000   000  000  0000  000   000       000
    0000000     0000000    0000000   000   000  0000000    0000000 
    ###
    
    saveBounds: ->
        log 'save bounds'
        bounds = prefs.get 'windows'
        for k, w of @wins
            bounds[k] = w.getBounds()
        prefs.set 'windows', bounds

    ###
     0000000   000   000  000  000000000
    000   000  000   000  000     000   
    000 00 00  000   000  000     000   
    000 0000   000   000  000     000   
     00000 00   0000000   000     000   
    ###
    
    beforeQuit: ->
        @saveBounds()
        for k, w of @wins
            w.removeAllListeners 'close'
        
    quit: ->
        log 'quit'
        app.quit()

module.exports = Main
