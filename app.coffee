###
 0000000   00000000   00000000 
000   000  000   000  000   000
000000000  00000000   00000000 
000   000  000        000      
000   000  000        000      
###

_       = require 'lodash'
fs      = require 'fs'
app     = require 'app'
Menu    = require 'menu'
dialog  = require 'dialog'
window  = require 'browser-window'
debugel = require 'electron-debug'
debugel showDevTools: false

log    = require './coffee/tools/log'
prefs  = require './coffee/tools/prefs'
wins   = {}

prefs.debug = false

prefs.init "/Users/kodi/Projects/strudl/prefs.json", # "#{app.getPath('userData')}/prefs.json", 
    open: []
    recent: []
    windows: []

loadPreferences = () ->
    
    p = prefs.load()
    
    for f in  p.recent
        app.addRecentDocument f
        
    for f in p.open
        loadFile f
        
preloadFile = (p) ->
    prefs.one 'open', p
        
loadFile = (p) ->
    
    if wins[p]?
        wins[p].focus()
        return
    
    cwd = __dirname

    w = new window
        dir: cwd
        preloadWindow: true
        resizable: true
        frame: true
        show: true
        center: false

    wd = prefs.get 'windows'
    w.setBounds wd[p] if wd[p]?
        
    w.on 'domLoaded', -> w.emit 'loadFile', p
    
    w.on 'close', (event) -> 
        log 'on window close'
        saveBounds()
        delete wins[_.findKey(wins, event.sender)]
        prefs.del 'open', p

    w.loadURL "file://#{cwd}/../win.html"

    wins[p] = w

    prefs.one 'open', p
    prefs.one 'recent', p

openFile = ->

    # log 'openFile'
    p = dialog.showOpenDialog
        properties: [ 'openFile']
        filters:    [ name: 'data', extensions: ['json', 'cson', 'plist'] ]
        properties: [ 'openFile', 'multiSelections' ]
        
    if p?.length?
        for f in p
            if fs.existsSync f
                loadFile f

saveBounds = ->
    log 'save bounds'
    bounds = prefs.get 'windows'
    for k, w of wins
        bounds[k] = w.getBounds()
    prefs.set 'windows', bounds

app.on 'before-quit', -> 
    saveBounds()
    for k, w of wins
        w.removeAllListeners 'close'
        
app.on 'will-quit', -> log 'on will-quit'
app.on 'quit', -> log 'on quit'    
app.on 'window-all-closed', -> log 'on window-all-closed'
app.on 'will-finish-launching', -> log 'on will-finish-launching'
app.on 'open-file', (e,p) -> preloadFile p
    
app.on 'ready', ->

    log 'app ready'
    
    app.removeAllListeners 'open-file'
    app.on 'open-file', (e,p) -> loadFile p
    
    ###
    00     00  00000000  000   000  000   000
    000   000  000       0000  000  000   000
    000000000  0000000   000 0 000  000   000
    000 0 000  000       000  0000  000   000
    000   000  00000000  000   000   0000000 
    ###
    
    menu = [
        label: 'Strudl'   
        submenu: [     
            label: 'Quit'
            accelerator: 'Command+Q'
            click: app.quit
        ]
    ,
        label: 'File'
        submenu: [
            label: 'Open...'
            accelerator: 'CmdOrCtrl+O'
            click: openFile
        ,
            type: 'separator'
        ,
            label: 'Reload'
            accelerator: 'CmdOrCtrl+R'
            click: (item, wind) -> wind?.reload()
        ]
    , 

        label: 'Window'
        submenu: [
            label: 'Toggle Full Screen'
            accelerator: process.platform == 'darwin' and 'Ctrl+Command+F' or 'F11'
            click: (item, wind) -> wind?.setFullScreen !wind.isFullScreen()
        ,
            label: 'Minimize'
            accelerator: 'CmdOrCtrl+M'
            role: 'minimize'
        ]
    ]

    Menu.setApplicationMenu Menu.buildFromTemplate menu
    
    loadPreferences()
