###
0000000     0000000    0000000  000   000  00     00  00000000  000   000  000   000
000   000  000   000  000       000  000   000   000  000       0000  000  000   000
000   000  000   000  000       0000000    000000000  0000000   000 0 000  000   000
000   000  000   000  000       000  000   000 0 000  000       000  0000  000   000
0000000     0000000    0000000  000   000  000   000  00000000  000   000   0000000 
###

prefs = require './tools/prefs'
Menu = require 'menu'
app  = require 'app'

class DockMenu 
    
    @init: (main) -> 
        
        recent = []
        for f in prefs.load().recent
            recent.push 
                label: f
                click: (i) -> main.loadFile i.label
        
        app.dock.setMenu Menu.buildFromTemplate [
            
            label: 'Open Recent'
            submenu: recent
        ]
        
module.exports = DockMenu
