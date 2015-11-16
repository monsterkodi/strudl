###
000   000  000  00000000  000   000  000  000000000  00000000  00     00
000   000  000  000       000 0 000  000     000     000       000   000
 000 000   000  0000000   000000000  000     000     0000000   000000000
   000     000  000       000   000  000     000     000       000 0 000
    0      000  00000000  00     00  000     000     00000000  000   000
###

log       = require './log'
Item      = require './item'
ProxyItem = require './proxyitem'

class ViewItem extends ProxyItem

    constructor: (@key, @value, prt) -> 
        super            

    createElement: ->
        
        if @key != -1
            log.debug 'createElement', @key
            @elem = @root().elem.appendChild document.createElement 'div'
            @elem.classList.add 'tree-item'
            @elem.id = "#{@keyPath().join('.')}"
        
            spc = document.createElement 'span'
            @elem.appendChild spc
            spc.addEventListener 'click', (event) => @clicked event
                
            spc.className = "tree-item-spc"
            spc.style.minWidth = "#{@depth()*30}.px"
            spc.innerHTML = "&nbsp;"
            if @isExpandable()
                spc.classList.add "collapsed"
            
            key = document.createElement 'span'
            @elem.appendChild key
            key.addEventListener 'click', (event) => @clicked event
            key.className = "tree-item-key type-" + @typeName().toLowerCase()
            key.innerHTML = @key
            
            val = document.createElement 'span'
            @elem.appendChild val
            val.className = "tree-item-value"
            
            switch @type
                when Item.objectType
                    val.innerHTML = "{}"
                when Item.arrayType
                    val.innerHTML = "[#{@getValue().length}]"
                when Item.valueType
                    val.innerHTML = @getValue()
    
    removeElement: ->
        log.debug 'removeElement', @elem
        @elem.remove()
        @elem = null
    
    delChild: (child) ->
        child.removeElement()
        super
        
    expand: (recursive=false) -> 
        super
        spc = @elem.getElementsByClassName('tree-item-spc')[0]
        @swapClass "collapsed", "expanded", spc
            
    collapse: (recursive=false) -> 
        log.debug item:@, 'collapse'
        super
        spc = @elem.getElementsByClassName('tree-item-spc')[0]
        log.debug 'swap', spc?
        @swapClass "expanded", "collapsed", spc
    
    clicked: (event) =>
        log.debug 'clicked', @isExpanded()
        
        # if @isExpanded()
        #     @collapse()
        # else
        #     @expand()
        
        if @hasClass 'selected'
            @toggle()
        else 
            @expand()

        # if event.shiftKey
        #     for item in @root.itemsInRange(@root.selected.listIndex, @listIndex)
        #         item.select event
        #     @select event
        # else if event.metaKey
        #     @toggleClass "marked"
        #     @ownClass "selected"
        #     @clrClass "temp"
        #     @root.selected = @
        # else
        #     @select event
        
        @select event

        # if not event.metaKey and not event.shiftKey
        #     @mark "exclusive"
        
        event.stopPropagation()
        
    deselect: -> @delClass "selected"
        
    select: (event) ->
        # type = "temp"
        # type = "extend" if event.shiftKey
        # type = "remove" if event.metaKey
        # @mark type
        
        # @addClass "selected"
        
        @ownClass "selected"
        @ownClass "marked"
        
        if @elem != document.activeElement
            @elem.focus()

    # mark: (type) =>
    #     oldtemp = document.getElementsByClassName("temp")[0]
    #     
    #     switch type
    #         when "extend"
    #             oldtemp = null
    #             @clrClass "temp"
    #             @addClass "marked"
    #         when "exclusive"
    #             oldtemp = null
    #             @ownClass "marked"
    #             @ownClass "temp"
    #         when "remove"
    #             @clrClass "temp"
    #             @delClass "marked"
    #         when "temp"
    #             if not @hasClass "marked"
    #                 @ownClass "temp"
    #                 @addClass "marked"
    #             else
    #                 @clrClass "temp"
    #         else
    #             log.error "ERROR"
    #             
    #     oldtemp?.classList.remove "marked"                
        
        
    hasClass: (clss,e=@elem) -> e.classList.contains clss
    delClass: (clss,e=@elem) -> e.classList.remove clss
    addClass: (clss,e=@elem) -> e.classList.add clss
    toggleClass: (clss,e=@elem) -> if e.classList.contains clss then e.classList.remove clss else e.classList.add clss
    swapClass: (delClss, addClss, e=@elem) -> 
        @delClass delClss, e
        @addClass addClss, e
        
    clrClass: (clss) -> 
        while document.getElementsByClassName(clss).length
            document.getElementsByClassName(clss)[0].classList.remove clss
            
    ownClass: (clss) ->
        @clrClass clss
        @elem?.classList.add clss
        
        
module.exports = ViewItem
