###
 0000000  000000000   0000000    0000000   00000000
000          000     000   000  000        000     
0000000      000     000000000  000  0000  0000000 
     000     000     000   000  000   000  000     
0000000      000     000   000   0000000   00000000
###

pos = require './pos'

class Stage

    @mousePos = pos 0, 0
    
    @init: =>
        stage = $('stage')
        stage.addEventListener 'mousemove',   Stage.onMove

    @onMove: (event) =>
        @mousePos = @absPos event

    @positionWindow: (win) =>
        [p, w, h] = [win.absPos(), win.getWidth(), win.getHeight()]
        [x,y] = [p.x, p.y]
        x = Math.min(x, @width() - w)
        y = Math.max(y, $('menu').getHeight()+6)
        win.setPos pos x, y

    @width:  => @size().width
    @height: => @size().height

    @size: =>
        s = window.getComputedStyle $('stage')
        width:  parseInt s.width
        height: parseInt s.height

    @windowAtPos: (p) =>
        e = @elementAtPos p
        e?.getWidget?().getWindow()
        
    @elementAtPos: (p) =>
        e = document.elementFromPoint p.x, p.y
        e or $('stage')

    @absPos: (event) =>
        event = if event? then event else window.event
        if isNaN window.scrollX
            return pos(event.clientX + document.documentElement.scrollLeft + document.body.scrollLeft,
                       event.clientY + document.documentElement.scrollTop + document.body.scrollTop)
        else
            return pos(event.clientX + window.scrollX, event.clientY + window.scrollY)

    @relPos: (event) =>
        event = if event? then event else window.event
        c = pos event.clientX, event.clientY
        t = event.target.getWidget().absPos()
        return c.sub t

module.exports = Stage
        
