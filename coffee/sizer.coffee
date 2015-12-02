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
        @pos = 0.5
        
    update: -> @elem.style.left = "#{@view.col('val').offsetLeft}px"
                
    hide: -> @elem.style.display = 'none'
    show: -> @elem.style.display = 'block'
        
    onDrag: (event) => 
        dx = event.clientX - @elem.offsetWidth - @x
        if dx
            if @view.onResizeColumn @x, dx
                if event.clientX
                    key = @view.col 'key'
                    val = @view.col 'val'
                    @pos = (event.clientX - key.offsetLeft) / (key.offsetWidth + val.offsetWidth)
            super
        
module.exports = Sizer
