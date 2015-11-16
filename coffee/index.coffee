###
000  000   000  0000000    00000000  000   000
000  0000  000  000   000  000        000 000 
000  000 0 000  000   000  0000000     00000  
000  000  0000  000   000  000        000 000 
000  000   000  0000000    00000000  000   000
###

path          = require 'path'
app           = require 'app'
BrowserWindow = require 'browser-window'

app.on 'ready', () ->

    cwd = path.join __dirname, '..'
    
    # 000   000  000  000   000
    # 000 0 000  000  0000  000
    # 000000000  000  000 0 000
    # 000   000  000  000  0000
    # 00     00  000  000   000

    win = new BrowserWindow
        dir:           cwd
        preloadWindow: true
        resizable:     true
        frame:         true
        show:          true
        center:        true

    win.loadUrl "file://#{cwd}/index.html"
