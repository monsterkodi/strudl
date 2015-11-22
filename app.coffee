###
 0000000   00000000   00000000 
000   000  000   000  000   000
000000000  00000000   00000000 
000   000  000        000      
000   000  000        000      
###

app = require 'app'
BrowserWindow = require 'browser-window'

app.on 'ready', ->
    cwd = undefined
    win = undefined
    cwd = __dirname
    win = new BrowserWindow(
        dir: cwd
        preloadWindow: true
        resizable: true
        frame: true
        show: true
        center: false)
    win.loadURL 'file://' + cwd + '/../win.html'
