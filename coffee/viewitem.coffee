###
000   000  000  00000000  000   000  000  000000000  00000000  00     00
000   000  000  000       000 0 000  000     000     000       000   000
 000 000   000  0000000   000000000  000     000     0000000   000000000
   000     000  000       000   000  000     000     000       000 0 000
    0      000  00000000  00     00  000     000     00000000  000   000
###

log       = require './tools/log'
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

            @idx = document.createElement 'div'
            @idx.className = "tree-item idx"
            @idx.innerHTML = "#{@value.visibleIndex} "
            @idx.id = "#{@indexInParent()}"
            
            
            @lin = document.createElement 'div'
            @lin.className = 'tree-line'
            @lin.addEventListener 'click', (event) => @clicked event
            @lin.tabIndex = -1
            @idx.appendChild @lin

            @elm = document.createElement 'div'
            @elm.className = "tree-item key"
            @elm.tabIndex = -1
        
            spc = document.createElement 'span'
            spc.addEventListener 'click', (event) => @clicked event, true
            spc.className = "tree-value spc"
            spc.style.minWidth = "#{@depth()*30}.px"
            spc.innerHTML = "&nbsp;"
            if @isExpandable()
                spc.classList.add @isExpanded() and "expanded" or "collapsed"
            @elm.appendChild spc
            
            key = document.createElement 'span'
            key.className = "tree-value key " + @typeName().toLowerCase()
            key.innerHTML = @key
            if @parent.type == Item.arrayType
                @addClass 'array-index', key
            @elm.appendChild key
            
            @val = document.createElement 'div'
            @val.className = "tree-item val " + @typeName().toLowerCase()

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
            vis = @getElem "vis", @num
            chd = @getElem "chd", @num
            dsc = @getElem "dsc", @num
            vis.innerHTML = (@isExpanded() and "#{@value.numVisible}" or "")
            chd.innerHTML = "#{@dataItem().children.length}"
            dsc.innerHTML = "#{@dataItem().numDescendants-1}"

        switch @type
            when Item.objectType
                @val.innerHTML = @getValue()["name"] or ""
            when Item.valueType
                @val.innerHTML = @getValue() ? "null"
                    
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

        toggle = true if @hasClass 'selected', @lin
        
        @select event
        
        @toggle() if toggle

        event.stopPropagation()
        
    ###
     0000000  00000000  000      00000000   0000000  000000000
    000       000       000      000       000          000   
    0000000   0000000   000      0000000   000          000   
         000  000       000      000       000          000   
    0000000   00000000  0000000  00000000   0000000     000   
    ###
        
    deselect: -> 
        @delClass "selected", @lin
        @root().elem.focus()
        
    select: (event) ->
        
        log 'select', @value.visibleIndex
        @model().selectIndex @value.visibleIndex
        
    focus: (event) ->
        @ownClass "selected", @lin
        
        if @elm != document.activeElement
            @elm.focus()        
                                                        
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
