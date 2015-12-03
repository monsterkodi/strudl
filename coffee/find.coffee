###
00000000  000  000   000  0000000  
000       000  0000  000  000   000
000000    000  000 0 000  000   000
000       000  000  0000  000   000
000       000  000   000  0000000  
###

now     = require 'performance-now'
log     = require './tools/log'
Emitter = require 'events'

class Find extends Emitter

    constructor: (@tree, @elem) ->
        @key = @getElem('input-key')
        @val = @getElem('input-val')
        @key.on 'input'  , @onInput
        @val.on 'input'  , @onInput
        @key.on 'blur'   , @onBlur
        @val.on 'blur'   , @onBlur
        @key.on 'focus'  , @onFocus
        @val.on 'focus'  , @onFocus
        @key.on 'keydown', @onKeyDown
        @val.on 'keydown', @onKeyDown
        @filterTime = 50

    onKeyDown: (event) =>
                
        keycode = keyname.keycode event
        switch keycode
            when 'esc'
                @clear()
            when 'enter'
                @applyFilter()
            when 'down'
                @emit 'blur'
            # else log 'keycode', keycode
            
    show: -> 
        if @elem.style.display == 'none' 
            @elem.style.display = 'block'
            true

    hide: -> 
        if @elem.style.display == 'block' 
            @elem.style.display = 'none'
            @emit 'hidden'
            true

    clear: ->
        @val.value = ''
        @key.value = ''
        @applyFilter()
        @hide()
    
    onInput: (event) => 
        # if @timer?
        #     clearTimeout @timer
        # @timer = setTimeout @applyFilter, Math.min(1000, @filterTime*2)
        
    onFocus: (event) =>
        if @blurTimer?
            clearTimeout @blurTimer
            @blurTimer = null
        
    onBlurTimer: (event) =>
        @blurTimer = null
        @emit 'blur'
        
    onBlur: (event) =>
        if document.activeElement not in [@key, @val]
            @blurTimer = setTimeout @onBlurTimer, 10
        
    applyFilter: =>
        @timer = null
        key = @key.value
        val = @val.value
        start = now()
        @tree.data().setFilter key, val
        @filterTime = parseInt now() - start
            
    ###
    00000000  000      00000000  00     00
    000       000      000       000   000
    0000000   000      0000000   000000000
    000       000      000       000 0 000
    00000000  0000000  00000000  000   000
    ###
                        
    getElem: (clss,e=@elem) -> e.getElementsByClassName(clss)[0]        

module.exports = Find
