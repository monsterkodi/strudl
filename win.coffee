###
000   000  000  000   000
000 0 000  000  0000  000
000000000  000  000 0 000
000   000  000  000  0000
00     00  000  000   000
###

_       = require 'lodash'
fs      = require 'fs'
ipc     = require 'ipc'
path    = require 'path'
remote  = require 'remote'
log     = require './js/coffee/tools/log'
keyname = require './js/coffee/tools/keyname'
Data    = require './js/coffee/data'
Proxy   = require './js/coffee/proxy'
View    = require './js/coffee/view'
app     = remote.require 'app'
win     = remote.getCurrentWindow()

debugMenu = require 'debug-menu'
debugMenu.install()

data    = null
prxy    = null
view    = null

win.on 'loadFile', (path) ->
    log 'on loadFile', path
    data = new Data()
    prxy = new Proxy data
    view = new View prxy, $('tree')
        
    log "\nloading data from file #{path}" 
    data.load path  

###
000       0000000    0000000   0000000    00000000  0000000  
000      000   000  000   000  000   000  000       000   000
000      000   000  000000000  000   000  0000000   000   000
000      000   000  000   000  000   000  000       000   000
0000000   0000000   000   000  0000000    00000000  0000000  
###

document.addEventListener 'DOMContentLoaded', () ->
    log 'win dom loaded'
    win.emit 'domLoaded'
        
win.on 'close',      (event) -> 
win.on 'focus',      (event) -> 
win.on 'blur',       (event) -> 
win.on 'maximize',   (event) -> 
win.on 'unmaximize', (event) -> 
    
###
00000000   00000000   0000000  000  0000000  00000000
000   000  000       000       000     000   000     
0000000    0000000   0000000   000    000    0000000 
000   000  000            000  000   000     000     
000   000  00000000  0000000   000  0000000  00000000
###

win.on 'resize', () -> view.update()
    
###
000   000  00000000  000   000  0000000     0000000   000   000  000   000
000  000   000        000 000   000   000  000   000  000 0 000  0000  000
0000000    0000000     00000    000   000  000   000  000000000  000 0 000
000  000   000          000     000   000  000   000  000   000  000  0000
000   000  00000000     000     0000000     0000000   00     00  000   000
###
            
document.addEventListener 'keydown', (event) ->
    key = keyname.ofEvent event
    e   = document.activeElement
    switch key
        when 'command+i'  then toggleStyle()
        when 'command+w'  then win.close()
        # else log "main.keydown", key, e

###
 0000000  000000000  000   000  000      00000000
000          000      000 000   000      000     
0000000      000       00000    000      0000000 
     000     000        000     000      000     
0000000      000        000     0000000  00000000
###

toggleStyle = ->
    link = $('style-link')
    currentScheme = link.href.split('/').last()
    schemes = ['dark.css', 'bright.css']
    nextSchemeIndex = ( schemes.indexOf(currentScheme) + 1) % schemes.length
    newlink = new Element 'link', 
        rel:  'stylesheet'
        type: 'text/css'
        href: 'style/'+schemes[nextSchemeIndex]
        id:   'style-link'

    link.parentNode.replaceChild newlink, link        
