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
log     = require './tools/log'
keyname = require './tools/keyname'
Data    = require './data'
Proxy   = require './proxy'
View    = require './view'
app     = remote.require 'app'
win     = remote.getCurrentWindow()

debugMenu = require 'debug-menu'
debugMenu.install()

data    = null
prxy    = null
view    = null

win.on 'findPath',  -> view.findPath()
win.on 'findValue', -> view.findValue()
win.on 'clearFind', -> view.find.clear()
win.on 'setColumnVisible', (c,v) -> view.setColumVisible c,v

loadFile = (p) ->
    
    data = new Data()
    prxy = new Proxy data
    view = new View prxy, document.getElementById 'tree'
        
    data.load p  
    
    win.setRepresentedFilename p

    title = path.basename p
    win.setTitle title

###
000       0000000    0000000   0000000    00000000  0000000  
000      000   000  000   000  000   000  000       000   000
000      000   000  000000000  000   000  0000000   000   000
000      000   000  000   000  000   000  000       000   000
0000000   0000000   000   000  0000000    00000000  0000000  
###

document.addEventListener 'DOMContentLoaded', () -> 
    loadFile win.filePath
    win.emit 'domLoaded'
        
###
00000000   00000000   0000000  000  0000000  00000000
000   000  000       000       000     000   000     
0000000    0000000   0000000   000    000    0000000 
000   000  000            000  000   000     000     
000   000  00000000  0000000   000  0000000  00000000
###

window.addEventListener 'resize', () -> view.update()
    
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
        # else log "main.keydown", event, key, e

###
 0000000  000000000  000   000  000      00000000
000          000      000 000   000      000     
0000000      000       00000    000      0000000 
     000     000        000     000      000     
0000000      000        000     0000000  00000000
###

toggleStyle = ->
    link = document.getElementById 'style-link'
    currentScheme   = _.last new String(link.href).split('/')
    schemes         = ['dark.css', 'bright.css']
    nextSchemeIndex = ( schemes.indexOf(currentScheme) + 1) % schemes.length
    
    newlink      = document.createElement 'link'
    newlink.rel  = 'stylesheet'
    newlink.type = 'text/css'
    newlink.href = 'style/'+schemes[nextSchemeIndex]
    newlink.id   = 'style-link'

    link.parentNode.replaceChild newlink, link        
