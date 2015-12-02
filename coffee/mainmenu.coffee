###
00     00   0000000   000  000   000  00     00  00000000  000   000  000   000
000   000  000   000  000  0000  000  000   000  000       0000  000  000   000
000000000  000000000  000  000 0 000  000000000  0000000   000 0 000  000   000
000 0 000  000   000  000  000  0000  000 0 000  000       000  0000  000   000
000   000  000   000  000  000   000  000   000  00000000  000   000   0000000 
###

fs    = require 'fs'
Menu  = require 'menu'
prefs = require './tools/prefs'
log   = require './tools/log'

class MainMenu
    
    @init: (main) -> 
    
        recent = []
        for f in prefs.load().recent
            if fs.existsSync f
                recent.push 
                    label: f
                    click: (i) -> main.loadFile i.label
            
        Menu.setApplicationMenu Menu.buildFromTemplate [
            
            label: 'Strudel'   
            submenu: [     
                label: 'About strudl'
                role: 'about'
            ,
                type: 'separator'
            ,
                label: 'Hide strudl'
                accelerator: 'Command+H'
                role: 'hide'
            ,
                label: 'Hide Others'
                accelerator: 'Command+Alt+H'
                role: 'hideothers'
            ,
                type: 'separator'
            ,
                label: 'Quit'
                accelerator: 'Command+Q'
                click: -> main.quit()
            ]
        ,
            ###
            00000000  000  000      00000000
            000       000  000      000     
            000000    000  000      0000000 
            000       000  000      000     
            000       000  0000000  00000000
            ###
            label: 'File'
            role: 'file'
            submenu: [
                label: 'Open...'
                accelerator: 'CmdOrCtrl+O'
                click: -> main.openFile()
            ,
                label: 'Open Recent'
                submenu: recent
            ,
                type: 'separator'
            ,
                label: 'Reload'
                accelerator: 'CmdOrCtrl+R'
                click: (i,win) -> win?.reload()
            ]
        ,
            ###
            00000000  000  000   000  0000000  
            000       000  0000  000  000   000
            000000    000  000 0 000  000   000
            000       000  000  0000  000   000
            000       000  000   000  0000000  
            ###
            label: 'Find'
            submenu: [
                label: 'Find Path'
                accelerator: 'CmdOrCtrl+F'
                click: (i,win) -> win?.emit 'findPath'
            ,
                label: 'Find Value'
                accelerator: 'CmdOrCtrl+G'
                click: (i,win) -> win?.emit 'findValue'
            ,
                label: 'Clear Find'
                accelerator: 'CmdOrCtrl+K'
                click: (i,win) -> win?.emit 'clearFind'
            ]
        ,        
            ###
            000   000  000  00000000  000   000
            000   000  000  000       000 0 000
             000 000   000  0000000   000000000
               000     000  000       000   000
                0      000  00000000  00     00
            ###
            label: 'View'
            role: 'view'
            submenu: [
                label: 'Index Column'
                accelerator: 'CmdOrCtrl+1'
                type: 'checkbox'
                checked: 'true'
                click: (i,win) -> win?.emit 'setColumnVisible', 'idx', i.checked
            ,
                label: 'Path Column'
                accelerator: 'CmdOrCtrl+2'
                type: 'checkbox'
                checked: 'true'
                click: (i,win) -> win?.emit 'setColumnVisible', 'key', i.checked
            ,
                label: 'Value Column'
                accelerator: 'CmdOrCtrl+3'
                type: 'checkbox'
                checked: 'true'
                click: (i,win) -> win?.emit 'setColumnVisible', 'val', i.checked
            ,
                label: 'Number Column'
                accelerator: 'CmdOrCtrl+4'
                type: 'checkbox'
                checked: 'true'
                click: (i,win) -> win?.emit 'setColumnVisible', 'num', i.checked
            ,
                type: 'separator'
            ,                
                label: 'Toggle FullScreen'
                accelerator: 'Ctrl+Command+F'
                click: (i,win) -> win?.setFullScreen !win.isFullScreen()
            ]
        ,        
            ###
            000   000  000  000   000  0000000     0000000   000   000
            000 0 000  000  0000  000  000   000  000   000  000 0 000
            000000000  000  000 0 000  000   000  000   000  000000000
            000   000  000  000  0000  000   000  000   000  000   000
            00     00  000  000   000  0000000     0000000   00     00
            ###
            label: 'Window'
            role: 'window'
            submenu: [
                label: 'Zoom'
                role: 'maximize'
            ,
                label: 'Bring All to Front'
                role: 'front'
            ,
                label: 'Minimize'
                accelerator: 'CmdOrCtrl+M'
                role: 'minimize'
            ]
        ,        
            label: 'Help'
            role: 'help'
            submenu: []            
        ]

module.exports = MainMenu
