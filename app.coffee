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

loadPreferences = () ->

    prefs.debug = false
    
    p = prefs.init "/Users/kodi/Projects/strudl/prefs.json", # "#{app.getPath('userData')}/prefs.json", 
        open: []
        recent: []
        windows: []

    for f in p.recent
        app.addRecentDocument f
        
    for f in p.open
        loadFile f
        
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
        
    w.on 'domLoaded', -> w.emit 'loadFile', p
    
    w.on 'close', (event) -> 
        log 'wins', Object.keys wins
        delete wins[_.findKey(wins, event.sender)]
        log 'wins', Object.keys wins
        prefs.del 'open', p

    w.loadURL "file://#{cwd}/../win.html"

    wd = prefs.get 'windows'
    w.setBounds wd[p] if wd[p]?

    wins[p] = w

    prefs.one 'open', p
    prefs.one 'recent', p

openFile = ->
    
    p = dialog.showOpenDialog
        properties: [ 'openFile']
        filters:    [ name: 'data', extensions: ['json', 'cson'] ]
        properties: [ 'openFile', 'multiSelections' ]
    for f in p 
        if fs.existsSync f
            loadFile f

saveStateAndExit = ->
    bounds = {}
    for k, w of wins
        bounds[k] = w.getBounds()
        w.removeAllListeners 'close'
    prefs.set 'windows', bounds
    app.quit()
    
app.on 'will-finish-launching', ->
        
app.on 'window-all-closed', -> app.exit 0
    
app.on 'ready', ->

    console.log 'app ready'
    
    menu = [
        label: 'strudl'   
        submenu: [     
            label: 'Quit'
            accelerator: 'Command+Q'
            click: saveStateAndExit
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
