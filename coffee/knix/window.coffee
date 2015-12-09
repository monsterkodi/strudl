###
000   000  000  000   000  0000000     0000000   000   000
000 0 000  000  0000  000  000   000  000   000  000 0 000
000000000  000  000 0 000  000   000  000   000  000000000
000   000  000  000  0000  000   000  000   000  000   000
00     00  000  000   000  0000000     0000000   00     00
###

Widget = require './widget'
stage  = require './stage'
str    = require './str'
def    = require './def'
log    = require '../tools/log'

class Window extends Widget

    constructor: (cfg, defs) -> super cfg, defs

    init: (cfg, defs) =>

        cfg = def cfg, defs
            
        children = cfg.children
        if cfg.child
            if not children? then children = []
            children.push cfg.child

        delete cfg.children
        delete cfg.child

        connect = cfg.connect
        delete cfg.connect

        super cfg,
            type      : 'window'
            class     : 'window' 
            parent    : 'stage'
            onDown    : @raise

        @initWindow()
        @config.children = children
        @insertChildren()
        @config.connect = connect
        @layoutChildren()

        if @config.popup then knix.addPopup @

        if @config.center
            @moveTo Math.max(0, stage.size().width/2 - @getWidth()/2), Math.max(0,stage.size().height/2 - @getHeight()/2)
            @config.center = undefined
        @

    postInit: => @sizeWindow()
    
    ###
    000  000   000  000  000000000  000   000  000  000   000  0000000     0000000   000   000
    000  0000  000  000     000     000 0 000  000  0000  000  000   000  000   000  000 0 000
    000  000 0 000  000     000     000000000  000  000 0 000  000   000  000   000  000000000
    000  000  0000  000     000     000   000  000  000  0000  000   000  000   000  000   000
    000  000   000  000     000     00     00  000  000   000  0000000     0000000   00     00
    ###

    initWindow: =>
                
        content = knix.create
            elem   : 'div',
            type   : 'content'
            parent : @elem.id

        @content = content

        if @config.content == 'scroll'

            content.elem.setStyle
                overflow : 'scroll'
                width    : '100%'
                height   : '100%'
                height   : "%dpx".fmt @contentHeight()

        @elem.on 'size', @sizeWindow
        @

    ###
    000       0000000   000   000   0000000   000   000  000000000
    000      000   000   000 000   000   000  000   000     000   
    000      000000000    00000    000   000  000   000     000   
    000      000   000     000     000   000  000   000     000   
    0000000  000   000     000      0000000    0000000      000   
    ###

    stretchWidth: => @

    sizeWindow: =>
        if @config.content == 'scroll'
            @content.setWidth  @contentWidth()
            @content.setHeight @contentHeight()

        for w in @allChildren()
            w.onWindowSize?()

    layoutChildren: =>
        e = @config.content? and $(@config.content) or @elem
        @setWidth e.getWidth()   if not @config.width?
        @setHeight e.getHeight() if not @config.height?

    ###
    00     00  000   0000000   0000000
    000   000  000  000       000     
    000000000  000  0000000   000     
    000 0 000  000       000  000     
    000   000  000  0000000    0000000
    ###
    
    isWindow: => true

    raise: (event) =>
        e = @scrollElem? and @scrollElem or @content.elem
        scrollx = e.scrollLeft
        scrolly = e.scrollTop
        @elem.parentElement.appendChild @elem
        e.scrollLeft = scrollx
        e.scrollTop = scrolly
        event?.stopPropagation()

    popup: (event) =>
        log 'popup', Stage.absPos event
        if @elem?
            @elem.show()
            @setPos Stage.absPos event
            @elem.raise()
        else
            warning 'no elem!'

    scrollToBottom: => @content.elem.scrollTop = @content.elem.scrollHeight
    scrollToTop:    => @content.elem.scrollTop = 0

    contentWidth:  => @elem.getLayout().get('padding-box-width')
    contentHeight: => @elem.getLayout().get('padding-box-height') - @headerSize()

    del: => @close()
    close: =>
        if @config.popup?
            knix.delPopup @
        super

module.exports = Window
