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

    constructor: (@key, @value, prt) -> super            

    ###
    00000000  000      00000000  00     00
    000       000      000       000   000
    0000000   000      0000000   000000000
    000       000      000       000 0 000
    00000000  0000000  00000000  000   000
    ###
    
    createElement: ->
        
        if @key != -1
            @elem = document.createElement 'div'

            @elem.addEventListener 'click', (event) => @clicked event
            @elem.classList.add 'tree-item'
            
            @elem.id = "#{@indexInParent()}"
            @elem.tabIndex = -1

            idx = document.createElement 'span'
            idx.className = "tree-item-idx"
            idx.innerHTML = "#{@value.visibleIndex} "
            @elem.appendChild idx
        
            spc = document.createElement 'span'
            spc.addEventListener 'click', (event) => @clicked event, true
            spc.className = "tree-item-spc"
            spc.style.minWidth = "#{@depth()*30}.px"
            spc.innerHTML = "&nbsp;"
            if @isExpandable()
                spc.classList.add @isExpanded() and "expanded" or "collapsed"
            @elem.appendChild spc
            
            key = document.createElement 'span'
            key.addEventListener 'click', (event) => @clicked event, true
            key.className = "tree-item-key type-" + @typeName().toLowerCase()
            key.innerHTML = @key
            if @parent.type == Item.arrayType
                @addClass 'array-index', key
            @elem.appendChild key
            
            val = document.createElement 'span'
            val.className = "tree-item-value type-" + @typeName().toLowerCase()
            @elem.appendChild val

            if @isParent()
                dsc = document.createElement 'span'
                dsc.className = "tree-item-dsc"
                @elem.appendChild dsc

                chd = document.createElement 'span'
                chd.className = "tree-item-chd"
                @elem.appendChild chd

                vis = document.createElement 'span'
                vis.className = "tree-item-vis"
                @elem.appendChild vis
            
            @update()
            
            @root().elem.appendChild @elem            
            
    update: ->
        if @isParent()
            vis = @getElem("tree-item-vis")
            chd = @getElem("tree-item-chd")
            dsc = @getElem("tree-item-dsc")
            vis.innerHTML = (@isExpanded() and "#{@value.numVisible}" or "")
            chd.innerHTML = "#{@dataItem().children.length}"
            dsc.innerHTML = "#{@dataItem().numDescendants-1}"

        val = @getElem("tree-item-value")
        switch @type
            when Item.objectType
                val.innerHTML = @getValue()["name"] or ""
            when Item.valueType
                val.innerHTML = @getValue()
                    
    removeElement: ->
        @elem.remove()
        @elem = null
    
    delChild: (child) ->
        child.removeElement()
        super
    
    nextItem: () -> @parent.children[@indexInParent()+1]
    prevItem: () -> @parent.children[@indexInParent()-1]
        
    ###
    00000000  000   000  00000000    0000000   000   000  0000000  
    000        000 000   000   000  000   000  0000  000  000   000
    0000000     00000    00000000   000000000  000 0 000  000   000
    000        000 000   000        000   000  000  0000  000   000
    00000000  000   000  000        000   000  000   000  0000000  
    ###
        
    expand: (recursive=false) ->
        super
        if @isExpandable()
            @swapClass "collapsed", "expanded", @getElem 'tree-item-spc'
            @update()
            
    collapse: (recursive=false) ->
        super
        if @isExpandable()
            @swapClass "expanded", "collapsed", @getElem 'tree-item-spc'
            @update()
    
    clicked: (event, toggle=false) =>

        toggle = true if @hasClass 'selected'
        @select event
        
        if toggle
            @toggle()

        event.stopPropagation()
        
    ###
     0000000  00000000  000      00000000   0000000  000000000
    000       000       000      000       000          000   
    0000000   0000000   000      0000000   000          000   
         000  000       000      000       000          000   
    0000000   00000000  0000000  00000000   0000000     000   
    ###
        
    deselect: -> 
        @delClass "selected"
        @root().elem.focus()
        
    select: (event) ->
        
        @ownClass "selected"
        
        if @elem != document.activeElement
            @elem.focus()
                                                        
    selectLeft: (event) -> 
        if event.metaKey
            @collapse true
        else if event.altKey
            @parent.select() if not @isTop()
        else if @isExpanded()
            @collapse()
        else
            @model().selectUp event
            
    selectRight: (event) -> 
        if event.metaKey
            @expand true
        else if @isExpandable() and not @isExpanded()
            @expand false
        else
            @model().selectDown event
            
    ###
     0000000  000       0000000   0000000
    000       000      000       000     
    000       000      0000000   0000000 
    000       000           000       000
     0000000  0000000  0000000   0000000 
    ###
        
    getElem:  (clss,e=@elem) -> e.getElementsByClassName(clss)[0]
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
