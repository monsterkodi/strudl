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

            if @parent == @root()
                @root().elem.appendChild @elem
            else
                @root().elem.insertBefore @elem, @parent.lastChild().elem.nextSibling

            @elem.classList.add 'tree-item'
            @elem.id = "#{@keyPath().join('.')}"
        
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
        @elem.remove()
        @elem = null
    
    delChild: (child) ->
        child.removeElement()
        super
    
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
            spc = @elem.getElementsByClassName('tree-item-spc')[0]
            @swapClass "collapsed", "expanded", spc
            
    collapse: (recursive=false) -> 
        super
        if @isExpandable()
            spc = @elem.getElementsByClassName('tree-item-spc')[0]
            @swapClass "expanded", "collapsed", spc
    
    clicked: (event, toggle=false) =>
        
        if toggle or @hasClass 'selected'
            @toggle()
        else 
            @expand()

        @select event

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
            
    ###
     0000000  000       0000000   0000000
    000       000      000       000     
    000       000      0000000   0000000 
    000       000           000       000
     0000000  0000000  0000000   0000000 
    ###
        
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
