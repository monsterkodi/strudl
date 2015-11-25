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
        
        @elem.style.left = "#{@view.col('val').offsetLeft}px"
        
    onDragStart: (event) =>
        @dot = document.createElement "div"
        @dot.id = "sizerDot"
        @dot.offsetLeft = event.screenX
        @dot.offsetTop = event.screenY
        document.body.appendChild @dot
        event.dataTransfer.dropEffect = 'none'
        event.dataTransfer.effectAllowed = 'none'
        event.dataTransfer.setDragImage @dot, @dot.offsetWidth/2, @dot.offsetHeight/2
        @x = event.clientX
                
    onDrag: (event) => 
        if @view.onResizeColumn @x, event.clientX - @x
            @elem.style.left = "#{event.clientX + @elem.offsetWidth}px" if event.clientX
        @dot.style.opacity = 0
        @x = event.clientX
        
    onDragEnter: (event) => 
        event.dataTransfer.dropEffect = 'none'
        event.dataTransfer.effectAllowed = 'none'
        
    onDragEnd: (event) => @dot.remove() #document.getElementById("sizerDot").remove()        
        
    pos: -> @elem.offsetLeft

module.exports = Sizer
