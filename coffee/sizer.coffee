###
 0000000  000  0000000  00000000  00000000 
000       000     000   000       000   000
0000000   000    000    0000000   0000000  
     000  000   000     000       000   000
0000000   000  0000000  00000000  000   000
###

Drag = require './drag'

class Sizer extends Drag

    constructor: (@view) ->
        
        super @view.tree.nextElementSibling.getElementsByClassName('sizer')[0]
        @elem.style.left = "#{@view.col('val').offsetLeft - @elem.offsetWidth}px"
        
    onDrag: (event) => 
        dx = event.clientX - @elem.offsetWidth - @x
        if dx
            if @view.onResizeColumn @x, dx
                @elem.style.left = "#{event.clientX}px" if event.clientX
            @dot.style.opacity = 0
            super
        
module.exports = Sizer
