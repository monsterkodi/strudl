###
0000000    00000000    0000000    0000000 
000   000  000   000  000   000  000      
000   000  0000000    000000000  000  0000
000   000  000   000  000   000  000   000
0000000    000   000  000   000   0000000 
###

EventEmitter = require 'events'

class Drag extends EventEmitter

    constructor: (@elem) ->
        super        
        @elem.style.pointerEvents = 'all'
        @elem.addEventListener 'mousedown', @onDragStart
                            
    onDragStart: (event) =>
        if event.target != @elem 
            return
        window.addEventListener 'mousemove', @onDrag
        window.addEventListener 'mouseup',   @onDragEnd

        @x = event.clientX - @elem.offsetWidth
        @y = event.clientY - @elem.offsetHeight
        @sx = event.clientX
        @sy = event.clientY
        @rx = @ry = 0
                
    onDrag: (event) =>
        if event.clientX or event.clientY
            @x = event.clientX - @elem.offsetWidth
            @y = event.clientY - @elem.offsetHeight
            [ox, oy] = [@rx, @ry]
            [@rx, @ry] = [event.clientX - @sx, event.clientY - @sy]
            [@dx, @dy] = [ox-@rx, oy-@ry]
            @emit 'drag', @
                
    onDragEnd: (event) => 
        window.removeEventListener 'mousemove', @onDrag
        window.removeEventListener 'mouseup',   @onDragEnd
        
    pos: -> @elem.offsetLeft

module.exports = Drag
