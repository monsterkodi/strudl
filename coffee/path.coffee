###
00000000    0000000   000000000  000   000
000   000  000   000     000     000   000
00000000   000000000     000     000000000
000        000   000     000     000   000
000        000   000     000     000   000
###

log = require './tools/log'

class Path

    constructor: (@elem) ->
    
    set: (@keys) ->

        @elem.innerHTML = ""
        odd = true
        idx = 0
        for key in @keys
            
            oddOrEven = odd and 'odd' or 'even'
            
            txt = document.createElement 'span'
            @elem.appendChild txt
            txt.className = "pathText"
            txt.classList.add oddOrEven
            txt.innerHTML = key
            
            arr = document.createElement 'span'
            @elem.appendChild arr
            arr.className = "pathArrow"
            arr.classList.add oddOrEven
            arr.classList.add 'last' if idx == @keys.length-1
            
            odd = not odd
            idx += 1

module.exports = Path
