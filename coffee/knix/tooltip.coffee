###
000000000   0000000    0000000   000      000000000  000  00000000 
   000     000   000  000   000  000         000     000  000   000
   000     000   000  000   000  000         000     000  00000000 
   000     000   000  000   000  000         000     000  000      
   000      0000000    0000000   0000000     000     000  000      
###

def    = require './def'
stage  = require './stage'
log    = require '../tools/log'
Window = require './window'

class Tooltip

    @create: (cfg, defs) =>
        cfg = def cfg, defs
        cfg = def cfg, 
                  delay : 2000
                  
        cfg.target.tooltip = cfg
        cfg.target.elem.on 'mousemove',  @onHover
        cfg.target.elem.on 'mouseleave', @onLeave
        cfg.target.elem.on 'mousedown',  @onLeave

    @onHover: (event, d) =>
        for e in [d, d.ancestors()].flatten()
            if e?.widget?.tooltip?
                tooltip = e.widget.tooltip
                if tooltip.window?
                    tooltip.window.close()
                    delete tooltip.window
                if tooltip.timer?
                    clearInterval tooltip.timer
                popup = -> Tooltip.popup(e, stage.absPos event)
                tooltip.timer = setInterval(popup, tooltip.delay)
                return

    @popup: (e, pos) =>
        tooltip = e.widget.tooltip
        if tooltip.timer?
            clearInterval tooltip.timer
            delete tooltip.timer
        if tooltip.onTooltip?
            text = tooltip.onTooltip()
        else if tooltip.text?
            text = tooltip.text
        else
            text = e.id
        tooltip.window = new Window
            class:     'tooltip'
            child:     
                text: text
                
        w = tooltip.window.getWidth()
        left = Math.max(0, Math.min(pos.x-w/2, stage.width()-w))
        tooltip.window.moveTo left, pos.y + 12

    @onLeave: (event, e) =>
        if tooltip = e?.widget?.tooltip
            if tooltip.timer?
                clearInterval tooltip.timer
                delete tooltip.timer
            if w = tooltip.window
                w.close()
                delete e.widget.tooltip.window

module.exports = Tooltip
