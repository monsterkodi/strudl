###
 0000000   00000000   00000000 
000   000  000   000  000   000
000000000  00000000   00000000 
000   000  000        000      
000   000  000        000      
###

main    = require './coffee/main'
debugel = require 'electron-debug'
debugel showDevTools: false # open console?

main.init()
