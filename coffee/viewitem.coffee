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

    updateElement: (@key, @value, prt) ->
        @parent = prt
        @visibleIndex = 0
            
        @type = @value.type
                    
        @children = []    if @isParent()
        @keyIndex = {}    if @isObject()
        @expanded = false if @isExpandable()
        
        @lin.className = 'tree-line line-' + String @value.visibleIndex
        @idx.innerHTML = "#{@value.visibleIndex} "
        @idx.id = "#{@indexInParent()}"
        
        spc = @elm.children[0]
        spc.className = "tree-value spc"
        spc.style.minWidth = "#{@depth()*30}.px"
        if @isExpandable()
            spc.classList.add @isExpanded() and "expanded" or "collapsed"
        else
            spc.classList.remove "expanded"
            spc.classList.remove "collapsed"
        
        @split = String(@key).split '►'
        @pth   = null
        key = @elm.children[1]
        key.className = "tree-value key " + @typeName().toLowerCase()
        key.innerHTML = ""
        if @split.length == 1
            key.innerHTML = @key
            if @parent.type == Item.arrayType
                @addClass 'array-index', key
        else
            @pth = new Path key
            @pth.set @split
            @pth.on 'keypath', @onKeyPath

        key.className = "tree-value key " + @typeName().toLowerCase()

        @update()
    
    createElement: ->
        
        if @key != -1

            @linc = document.createElement 'div'
            @linc.className = "tree-item linc"

            @lin = document.createElement 'span'
            @lin.className = 'tree-line line-' + String @value.visibleIndex
            @lin.addEventListener 'mousedown', @onMouseDown
            @lin.addEventListener 'focus',     @onFocus
            @lin.addEventListener 'blur',      @onBlur
            @lin.tabIndex = -1
            @linc.appendChild @lin

            @idx = document.createElement 'div'
            @idx.className = "tree-item idx"
            @idx.innerHTML = "#{@value.visibleIndex} "
            @idx.id = "#{@indexInParent()}"
            
            @elm = document.createElement 'div'
            @elm.addEventListener 'mousedown', @onMouseDown
            @elm.addEventListener 'focus',     @onFocus
            @elm.addEventListener 'blur',      @onBlur
            @elm.className = "tree-item key"
            @elm.tabIndex = -1
            
            new Drag @elm
                .on 'drag', @model().onDrag 
        
            spc = document.createElement 'span'
            spc.addEventListener 'mousedown', (event) => @onMouseDown event, true
            spc.className = "tree-value spc"
            spc.style.minWidth = "#{@depth()*30}.px"
            spc.innerHTML = "&nbsp;"
                        
            new Drag spc
                .on 'drag', @model().onDrag 

            if @isExpandable()
                spc.classList.add @isExpanded() and "expanded" or "collapsed"
            @elm.appendChild spc
            
            @split = String(@key).split '►'
            
            key = document.createElement 'span'
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
            @val.addEventListener 'mousedown', @onMouseDown
            @val.addEventListener 'focus',     @onFocus
            @val.addEventListener 'blur',      @onBlur
            @val.addEventListener 'mouseover', @onMouseOver
            @val.addEventListener 'mouseout',  @onMouseOut

            new Drag @val
                .on 'drag', @model().onDrag 

            val = document.createElement 'span'
            val.className = "tree-value val"
            @val.appendChild val

            @num = document.createElement 'div'
            @num.className = "tree-item num"
                
            dsc = document.createElement 'span'
            dsc.className = "tree-value dsc"
        
            chd = document.createElement 'span'
            chd.className = "tree-value chd"
                        
            @num.appendChild dsc
            @num.appendChild chd
            
            @col('lin').appendChild @linc
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
            (@getElem 'dsc', @num).innerHTML = "#{@dataItem().numDescendants-1}"
            (@getElem 'chd', @num).innerHTML = "#{@dataItem().children.length}"
        else  
            (@getElem 'dsc', @num).innerHTML = ""  
            (@getElem 'chd', @num).innerHTML = ""

        switch @type
            when Item.objectType
                @val.firstElementChild.innerHTML = @getValue()['name'] or ''
            when Item.valueType
                @val.firstElementChild.innerHTML = @getValue() ? 'null'
                    
    removeElement: ->
        @col('lin').removeChild @linc
        @col('idx').removeChild @idx
        @col('key').removeChild @elm         
        @col('val').removeChild @val
        @col('num').removeChild @num
    
    delChild: (child) ->
        child.removeElement()
        super 
    
    nextItem: () -> @parent.children[@indexInParent()+1]
    prevItem: () -> @parent.children[@indexInParent()-1]
        
    ###
    00     00   0000000   000   000   0000000  00000000
    000   000  000   000  000   000  000       000     
    000000000  000   000  000   000  0000000   0000000 
    000 0 000  000   000  000   000       000  000     
    000   000   0000000    0000000   0000000   00000000
    ###
        
    onMouseDown: (event, toggle=false) =>
        
        # preventDefault here breaks selection!
        event.stopPropagation()
        
        if not @isExpanded() and @hasClass 'selected', @lin
            toggle = true 
            
        @setFocus()
        @select event
        
        if toggle
            @toggle()
        
    onMouseMove: (event) =>
    onMouseUp: (event) =>
    
    onKeyPath: (keypath) => 
        @model().data().setFilter keypath.join '.'
        
    ###
    00000000   0000000    0000000  000   000   0000000
    000       000   000  000       000   000  000     
    000000    000   000  000       000   000  0000000 
    000       000   000  000       000   000       000
    000        0000000    0000000   0000000   0000000 
    ###
        
    hasFocus: => document.activeElement in [@lin, @val, @elm]

    setFocus: () => @lin.focus()   
                
    onFocus: (event) => 
        @ownClass 'focus', @lin
        @ownClass 'selected', @lin
        @ownClass 'tree-line-focus', event.target
        event.target.tabIndex = 2
        setTimeout @focusAgain, 10 # wtf?
                
    focusAgain: () =>
        if @hasClass('selected', @lin) and document.activeElement == document.body
            @setFocus()
    
    onBlur: (event) => 
        @clrClass 'focus', @lin
        @clrClass 'tree-line-focus', event.target
        event.target.tabIndex = -1
                        
    ###
     0000000  00000000  000      00000000   0000000  000000000
    000       000       000      000       000          000   
    0000000   0000000   000      0000000   000          000   
         000  000       000      000       000          000   
    0000000   00000000  0000000  00000000   0000000     000   
    ###
                                
    select: -> 
        @model().selectIndex @value.visibleIndex
        @setSelected()
        
    setSelected: () -> @ownClass 'selected', @lin
                                                        
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
     0000000   0000000  00000000    0000000   000      000    
    000       000       000   000  000   000  000      000    
    0000000   000       0000000    000   000  000      000    
         000  000       000   000  000   000  000      000    
    0000000    0000000  000   000   0000000   0000000  0000000
    ###
        
    onMouseOver: (event) => @val.addEventListener    'wheel', @onWheel
    onMouseOut: (event)  => @val.removeEventListener 'wheel', @onWheel
         
    onWheel: (event) =>
        if @scrollable() and Math.abs(event.deltaX) > Math.abs(event.deltaY)
            if @val.firstElementChild.style.position != 'absolute'
                @val.firstElementChild.style.position = 'absolute'
                @val.firstElementChild.style.left = '0'
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
