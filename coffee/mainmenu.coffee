###
00     00   0000000   000  000   000  00     00  00000000  000   000  000   000
000   000  000   000  000  0000  000  000   000  000       0000  000  000   000
000000000  000000000  000  000 0 000  000000000  0000000   000 0 000  000   000
000 0 000  000   000  000  000  0000  000 0 000  000       000  0000  000   000
000   000  000   000  000  000   000  000   000  00000000  000   000   0000000 
###

Menu  = require 'menu'
prefs = require './tools/prefs'
log   = require './tools/log'

class MainMenu
    
    @init: (main) -> 
    
        recent = []
        for f in prefs.load().recent
            recent.push 
                label: f
                click: (i) -> main.loadFile i.label
            
        Menu.setApplicationMenu Menu.buildFromTemplate [
            
            label: 'Strudel'   
            submenu: [     
                label: 'About Strudl'
                role: 'about'
            ,
                type: 'separator'
            ,
                label: 'Hide Strudl'
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
        # , 
        #     label: 'Edit'
        #     submenu: []
        ,        
            label: 'View'
            role: 'view'
            submenu: [
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
