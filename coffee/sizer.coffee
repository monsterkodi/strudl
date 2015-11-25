###
 0000000  000  0000000  00000000  00000000 
000       000     000   000       000   000
0000000   000    000    0000000   0000000  
     000  000   000     000       000   000
0000000   000  0000000  00000000  000   000
###

class Sizer

    constructor: (@view) ->
        
        @elem = @view.tree.nextElementSibling.getElementsByClassName('sizer')[0]
        @elem.draggable = true
        
        @elem.addEventListener 'drag',      @onDrag
        @elem.addEventListener 'dragstart', @onDragStart
        @elem.addEventListener 'dragend',   @onDragEnd
        @elem.addEventListener 'dragenter', @onDragEnter
        
        @elem.style.left = "#{@view.col('val').offsetLeft - @elem.offsetWidth}px"
        
    onDragStart: (event) =>
        @dot = document.createElement "div"
        @dot.className = "sizerDot"
        @dot.offsetLeft = event.screenX
        @dot.offsetTop = event.screenY
        document.body.appendChild @dot
        event.dataTransfer.dropEffect = 'none'
        event.dataTransfer.effectAllowed = 'none'
        event.dataTransfer.setDragImage @dot, @dot.offsetWidth/2, @dot.offsetHeight/2
        @x = event.clientX - @elem.offsetWidth
                
    onDrag: (event) => 
        dx = event.clientX - @elem.offsetWidth - @x
        if dx
            if @view.onResizeColumn @x, dx
                @elem.style.left = "#{event.clientX}px" if event.clientX
            @dot.style.opacity = 0
            @x = event.clientX - @elem.offsetWidth
        
    onDragEnter: (event) => 
        event.dataTransfer.dropEffect = 'none'
        event.dataTransfer.effectAllowed = 'none'
        
    onDragEnd: (event) => @dot.remove()
        
    pos: -> @elem.offsetLeft

module.exports = Sizer
