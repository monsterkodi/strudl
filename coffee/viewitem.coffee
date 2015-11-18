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

            @root().elem.appendChild @elem

            @elem.addEventListener 'click', (event) => @clicked event
            @elem.classList.add 'tree-item'
            
            @elem.id = "#{@indexInParent()}"
            @elem.tabIndex = -1

            idx = document.createElement 'span'
            @elem.appendChild idx
            idx.innerHTML = "#{@value.visibleIndex?()} "
        
            spc = document.createElement 'span'
            @elem.appendChild spc
            spc.addEventListener 'click', (event) => @clicked event, true
                
            spc.className = "tree-item-spc"
            spc.style.minWidth = "#{@depth()*30}.px"
            spc.innerHTML = "&nbsp;"
            if @isExpandable()
                spc.classList.add @isExpanded() and "expanded" or "collapsed"
            
            key = document.createElement 'span'
            @elem.appendChild key
            key.className = "tree-item-key type-" + @typeName().toLowerCase()
            key.innerHTML = @key
            if @parent.type == Item.arrayType
                @addClass 'array-index', key
            
            val = document.createElement 'span'
            @elem.appendChild val
            val.className = "tree-item-value type-" + @typeName().toLowerCase()
            
            @update()
            
    update: ->
        val = @getElem("tree-item-value")
        switch @type
            when Item.objectType
                val.innerHTML = (@getValue()["name"] or "") + (@isExpanded() and " <#{@numDescendants()}> <#{@value.numVisible}>" or "")
            when Item.arrayType
                val.innerHTML = "[#{@getValue().length}-#{@dataItem().numDescendants()}]" + (@isExpanded() and " <#{@numDescendants()}> <#{@value.numVisible}>" or "")
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

        @select event
        
        if toggle or @hasClass 'selected'
            @toggle()
        else 
            @expand()

        event.stopPropagation()
        
    ###
     0000000  00000000  000      00000000   0000000  000000000
    000       000       000      000       000          000   
    0000000   0000000   000      0000000   000          000   
         000  000       000      000       000          000   
    0000000   00000000  0000000  00000000   0000000     000   
    ###
        
    deselect: -> @delClass "selected"
        
    select: (event) ->
        
        @ownClass "selected"
        
        if @elem != document.activeElement
            @elem.focus()
            
    selectUp: (event) ->
        if @prevItem()
            @prevItem().select event
        else
            @model().scrollLines -1
            @model().selectUp()
            
    selectDown: (event) -> 
        if @nextItem()
            @nextItem().select event
        else
            @model().scrollLines 1  
            @model().selectDown()  
                                            
    selectLeft: (event) -> 
        if event.metaKey
            @collapse true
        else if event.altKey
            @parent.select() if not @isTop()
        else if @isExpanded()
            @collapse()
        else if not @isTop() 
            @selectUp event
            
    selectRight: (event) -> 
        if @isExpandable() and not @isExpanded()
            recursive = event.metaKey
            @expand recursive 
        else if @nextItem()?.topItem() == @topItem()
            @selectDown event
            
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