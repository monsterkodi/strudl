###
000   000  000  00000000  000   000  000  000000000  00000000  00     00
000   000  000  000       000 0 000  000     000     000       000   000
 000 000   000  0000000   000000000  000     000     0000000   000000000
   000     000  000       000   000  000     000     000       000 0 000
    0      000  00000000  00     00  000     000     00000000  000   000
###

_         = require 'lodash'
log       = require './tools/log'
Item      = require './item'
Drag      = require './drag'
Path      = require './path'
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

            @idx = document.createElement 'div'
            @idx.className = "tree-item idx"
            @idx.innerHTML = "#{@value.visibleIndex} "
            @idx.id = "#{@indexInParent()}"
            
            @lin = document.createElement 'span'
            @lin.className = 'tree-line'
            @lin.addEventListener 'click', @onClick
            @lin.tabIndex = -1
            @idx.appendChild @lin

            @elm = document.createElement 'div'
            @elm.className = "tree-item key"
            @elm.tabIndex = -1
            
            new Drag @elm
                .on 'drag', @model().onDrag 
        
            spc = document.createElement 'span'
            spc.addEventListener 'click', (event) => @onClick event, true
            spc.className = "tree-value spc"
            spc.style.minWidth = "#{@depth()*30}.px"
            spc.innerHTML = "&nbsp;"
                        
            new Drag spc
                .on 'drag', @model().onDrag 

            if @isExpandable()
                spc.classList.add @isExpanded() and "expanded" or "collapsed"
            @elm.appendChild spc
            @elm.addEventListener 'click', @onClick
            @elm.addEventListener 'blur', @onBlur
            @elm.addEventListener 'focus', @onFocus
            
            @split = String(@key).split '►'
            
            key = document.createElement 'span'
            key.addEventListener 'click', @onClick            
            key.className = "tree-value key " + @typeName().toLowerCase()
            
            if @split.length == 1
                key.innerHTML = @key
                if @parent.type == Item.arrayType
                    @addClass 'array-index', key
            else
                @pth = new Path key
                @pth.set @split
                @pth.on 'keypath', @onKeyPath
                
            @elm.appendChild key
            
            @val = document.createElement 'div'
            @val.className = "tree-item val " + @typeName().toLowerCase()
            @val.addEventListener 'wheel', @onWheel
            @val.addEventListener 'click', @onClick
            @valDrag = new Drag @val
            @valDrag.on 'drag', @onValDrag

            val = document.createElement 'span'
            val.className = "tree-value val"
            @val.appendChild val

            @num = document.createElement 'div'
            @num.className = "tree-item num"
                
            if @isParent()
                dsc = document.createElement 'span'
                dsc.className = "tree-value dsc"
            
                chd = document.createElement 'span'
                chd.className = "tree-value chd"
            
                vis = document.createElement 'span'
                vis.className = "tree-value vis"
                
                @num.appendChild dsc
                @num.appendChild chd
                @num.appendChild vis
            
            @col('idx').appendChild @idx
            @col('key').appendChild @elm         
            @col('val').appendChild @val
            @col('num').appendChild @num
                        
            @update()
            
    col: (name) -> @getElem name, @root().elem
                                    
    ###
    000   000  00000000   0000000     0000000   000000000  00000000
    000   000  000   000  000   000  000   000     000     000     
    000   000  00000000   000   000  000000000     000     0000000 
    000   000  000        000   000  000   000     000     000     
     0000000   000        0000000    000   000     000     00000000
    ###
            
    update: ->
        
        if @isParent()
            vis = @getElem 'vis', @num
            chd = @getElem 'chd', @num
            dsc = @getElem 'dsc', @num
            vis.innerHTML = (@isExpanded() and "#{@value.numVisible}" or "")
            chd.innerHTML = "#{@dataItem().children.length}"
            dsc.innerHTML = "#{@dataItem().numDescendants-1}"

        switch @type
            when Item.objectType
                @val.firstElementChild.innerHTML = @getValue()['name'] or ''
            when Item.valueType
                @val.firstElementChild.innerHTML = @getValue() ? 'null'
                    
    removeElement: ->
        @elm.remove()
        @idx.remove()
        @val.remove()
        @num.remove()
    
    delChild: (child) ->
        child.removeElement()
        super 
    
    nextItem: () -> @parent.children[@indexInParent()+1]
    prevItem: () -> @parent.children[@indexInParent()-1]
        
    ###
     0000000  000      000   0000000  000   000
    000       000      000  000       000  000 
    000       000      000  000       0000000  
    000       000      000  000       000  000 
     0000000  0000000  000   0000000  000   000
    ###
        
    onClick: (event, toggle=false) =>
        toggle = true if @hasClass 'selected', @lin
        @focus()
        if toggle
            @toggle()
        @select event
        event.stopPropagation()
    
    onKeyPath: (keypath) => 
        # log 'onKeyPath', keypath.join '.'
        @model().data().setFilter keypath.join '.'
        
    ###
     0000000   0000000  00000000    0000000   000      000    
    000       000       000   000  000   000  000      000    
    0000000   000       0000000    000   000  000      000    
         000  000       000   000  000   000  000      000    
    0000000    0000000  000   000   0000000   0000000  0000000
    ###
        
    onValDrag: (drag) => 
            if @scrollable()
                @scrollBy drag.dx

    onWheel: (event) =>
        if @scrollable() and Math.abs(event.deltaX) > Math.abs(event.deltaY)
            @scrollBy event.deltaX
            event.stopPropagation()
            
    scrollable: -> @val.clientWidth < @val.firstElementChild.clientWidth
    scrollBy: (delta) ->
            v = @val.firstElementChild
            left = @getLeft(v) - delta
            left = Math.min 0, left
            left = Math.max left, -v.offsetWidth
            @setLeft v, left
        
    ###
     0000000  00000000  000      00000000   0000000  000000000
    000       000       000      000       000          000   
    0000000   0000000   000      0000000   000          000   
         000  000       000      000       000          000   
    0000000   00000000  0000000  00000000   0000000     000   
    ###
        
    deselect: -> 
        @delClass 'selected', @lin
        @delClass 'focus', @lin
        @elm.tabIndex = -1  
        @root().elem.focus()
        
    select: ->
        log 'viewitem.select', @value.visibleIndex
        @model().selectIndex @value.visibleIndex
        
    onBlur: => @clrClass 'focus'
    onFocus: => @ownClass 'focus', @lin
    
    hasFocus: => document.activeElement == @elm
        
    focus: (event) ->
        @ownClass 'selected', @lin
        @ownClass 'focus', @lin
        if @elm != document.activeElement
            @elm.focus()   
            @elm.tabIndex = 2     
                                                        
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
        
    getLeft: (e) -> parseInt window.getComputedStyle(e).left
    setLeft: (e,w) -> e.style.left = "#{w}px"
        
    getElem:  (clss,e=@elm) -> e.getElementsByClassName(clss)[0]
    hasClass: (clss,e=@elm) -> e.classList.contains clss
    delClass: (clss,e=@elm) -> e.classList.remove clss
    addClass: (clss,e=@elm) -> e.classList.add clss
    toggleClass: (clss,e=@elm) -> if e.classList.contains clss then e.classList.remove clss else e.classList.add clss
    swapClass: (delClss, addClss, e=@elm) -> 
        @delClass delClss, e
        @addClass addClss, e
        
    clrClass: (clss) -> 
        while document.getElementsByClassName(clss).length
            document.getElementsByClassName(clss)[0].classList.remove clss
            
    ownClass: (clss,e=@elm) ->
        @clrClass clss
        e?.classList.add clss
        
        
module.exports = ViewItem
