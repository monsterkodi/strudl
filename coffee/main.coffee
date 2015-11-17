###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###

_       = require 'lodash'
fs      = require 'fs'
ipc     = require 'ipc'
remote  = require 'remote'
log     = require './log'
keyname = require './keyname'
Data    = require './data'
Proxy   = require './proxy'
View    = require './view'

app     = remote.require 'app'
win     = remote.getCurrentWindow()

data    = null
prxy    = null
view    = null

loadData = () ->
    data = new Data()
    prxy = new Proxy data
    view = new View prxy, $('tree')
    data.load 'data/data.json'

###
000       0000000    0000000   0000000    00000000  0000000  
000      000   000  000   000  000   000  000       000   000
000      000   000  000000000  000   000  0000000   000   000
000      000   000  000   000  000   000  000       000   000
0000000   0000000   000   000  0000000    00000000  0000000  
###

document.addEventListener 'DOMContentLoaded', loadData
        
win.on 'close',      (event) -> app.quit()
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

win.on 'resize', (event,e) -> 
    view.resize win.getContentSize()
    
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
        else log "main.keydown", key, e

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
