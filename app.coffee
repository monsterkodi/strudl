###
 0000000   00000000   00000000 
000   000  000   000  000   000
000000000  00000000   00000000 
000   000  000        000      
000   000  000        000      
###

debugel = require 'electron-debug'
prefs   = require './coffee/tools/prefs'
main    = require './coffee/main'

debugel showDevTools: false # open console?
prefs.debug = false         # log prefs

prefs.init "/Users/kodi/Projects/strudl/prefs.json", # "#{app.getPath('userData')}/prefs.json", 
    open: []
    recent: []
    windows: []

main.init()


