###
00000000    0000000   000000000  000   000
000   000  000   000     000     000   000
00000000   000000000     000     000000000
000        000   000     000     000   000
000        000   000     000     000   000
###

_       = require 'lodash'
log     = require './tools/log'
Emitter = require 'events'

class Path extends Emitter

    constructor: (@elem) ->
        
        @elem.addEventListener 'click', @onClick
        @elem.tabIndex = -1
        
    onClick: (event) => 
        idx = event.target.idx
        @emit 'keypath', @keys.slice(0,idx+1) if idx?
    
    set: (@keys) ->
        @elem.innerHTML = ""
        if @keys.length
            keys = String(@keys[0]).split('►')
            keys.push.apply keys, @keys.slice(1)

            odd = true
            idx = 0
            for key in keys
                
                oddOrEven = odd and 'odd' or 'even'
                
                txt = document.createElement 'span'
                @elem.appendChild txt
                txt.className = "pathText"
                txt.classList.add oddOrEven
                txt.innerHTML = key
                txt.idx = idx
                
                arr = document.createElement 'span'
                @elem.appendChild arr
                arr.className = "pathArrow"
                arr.classList.add oddOrEven
                arr.classList.add 'last' if idx == keys.length-1
                arr.idx = idx
                
                odd = not odd
                idx += 1

module.exports = Path
