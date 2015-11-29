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
        @key.on 'input', @onChanged
        @val.on 'input', @onChanged
        @val.addEventListener 'blur', => @emit 'blur'
            
    onChanged: (event) => 
        if @timer?
            clearTimeout @timer
        @timer = setTimeout @applyFilter, 500
        
    applyFilter: =>
        @timer = null
        key = @key.value
        val = @val.value
        @tree.data().setFilter key, val
            
    ###
    00000000  000      00000000  00     00
    000       000      000       000   000
    0000000   000      0000000   000000000
    000       000      000       000 0 000
    00000000  0000000  00000000  000   000
    ###
                        
    getElem: (clss,e=@elem) -> e.getElementsByClassName(clss)[0]        

module.exports = Find
