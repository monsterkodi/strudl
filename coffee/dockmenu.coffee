###
0000000     0000000    0000000  000   000  00     00  00000000  000   000  000   000
000   000  000   000  000       000  000   000   000  000       0000  000  000   000
000   000  000   000  000       0000000    000000000  0000000   000 0 000  000   000
000   000  000   000  000       000  000   000 0 000  000       000  0000  000   000
0000000     0000000    0000000  000   000  000   000  00000000  000   000   0000000 
###

fs    = require 'fs'
app   = require 'app'
Menu  = require 'menu'
prefs = require './tools/prefs'

class DockMenu 
    
    @init: (main) -> 
        
        recent = []
        for f in prefs.load().recent
            if fs.existsSync f
                recent.push 
                    label: f
                    click: (i) -> main.loadFile i.label
        
        app.dock.setMenu Menu.buildFromTemplate [
            
            label: 'Open Recent'
            submenu: recent
        ]
        
module.exports = DockMenu
