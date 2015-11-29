###
00000000  000  000   000  0000000  
000       000  0000  000  000   000
000000    000  000 0 000  000   000
000       000  000  0000  000   000
000       000  000   000  0000000  
###

log     = require './tools/log'
Emitter = require 'events'

class Find extends Emitter

    constructor: (@tree, @elem) ->
        @key = @getElem('input-key')
        @val = @getElem('input-val')
        @key.on 'change', @onKeyChanged
        @val.on 'change', @onValChanged
        @val.addEventListener 'blur', => @emit 'blur'
            
    onKeyChanged: (event) => 
        log 'keychange', event.target.value
        log (@tree.data().findKey event.target.value).length
        
    onValChanged: (event) => 
        log 'valchange', event.target.value    
        log (@tree.data().findValue event.target.value).length
    
    ###
    00000000  000      00000000  00     00
    000       000      000       000   000
    0000000   000      0000000   000000000
    000       000      000       000 0 000
    00000000  0000000  00000000  000   000
    ###
                        
    getElem: (clss,e=@elem) -> e.getElementsByClassName(clss)[0]        

module.exports = Find
