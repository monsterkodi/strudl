###
000   000  000  00000000  000   000
000   000  000  000       000 0 000
 000 000   000  0000000   000000000
   000     000  000       000   000
    0      000  00000000  00     00
###

_        = require 'lodash'
log      = require './log'
Model    = require './model'
Proxy    = require './proxy'
Item     = require './item'
ViewItem = require './viewitem'
keyname  = require './keyname'

class View extends Proxy
        
    constructor: (base, @tree) -> 
        super base, 'view', @tree
        @tree.addEventListener 'keydown', @onKeyDown
        @tree.parentElement.addEventListener 'scroll',  @onScroll
        
    setBase: (base) ->
        super base
        @base.on "didExpand",   @onDidExpand
        @base.on "didCollapse", @onDidCollapse

    ###
     0000000   0000000  00000000    0000000   000      000    
    000       000       000   000  000   000  000      000    
    0000000   000       0000000    000   000  000      000    
         000  000       000   000  000   000  000      000    
    0000000    0000000  000   000   0000000   0000000  0000000
    ###
        
    scrollLines: (lines) ->
        scroll = @tree.parentElement
        line   = @root?.children[0]?.elem.clientHeight or 24
        scroll.scrollTop += lines * line
        @update()

    onScroll: (event) => @update()

    ###
    000   000  00000000   0000000     0000000   000000000  00000000
    000   000  000   000  000   000  000   000     000     000     
    000   000  00000000   000   000  000000000     000     0000000 
    000   000  000        000   000  000   000     000     000     
     0000000   000        0000000    000   000     000     00000000
    ###
        
    update: ->

        selected = @root.children[parseInt(document.activeElement.id)]?.value?.id
        visible  = @base.numVisible()
        scroll   = @tree.parentElement
        line     = @root?.children[0]?.elem.clientHeight or 24
        numlines = parseInt(scroll.clientHeight / line)
        total    = visible * line
        height   = line * numlines
        first    = Math.min(Math.max(0, visible - numlines), parseInt(scroll.scrollTop / line))
        last     = first + numlines
            
        @root.children = []
        @root.keyIndex = {}
        @tree.innerHTML = "" # proper destruction needed?
                                        
        for i in [first..last]
            baseItem = @base.visibleAtIndex i
            @root.keyIndex[baseItem.key] = @root.children.length
            item = @createItem baseItem.key, baseItem, @root
            @root.children.push item
            item.createElement()     
            item.elem.style.top = "#{i*line}.px"  
            if baseItem.id == selected
                item.select()
                                
        if Number.isNaN parseInt(document.activeElement.id)
            @root.children[0]?.select()

        @tree.style.height = "#{total}.px"
        # log @tree.style.height
                          
    ###
    00000000   00000000  000       0000000    0000000   0000000  
    000   000  000       000      000   000  000   000  000   000
    0000000    0000000   000      000   000  000000000  000   000
    000   000  000       000      000   000  000   000  000   000
    000   000  00000000  0000000   0000000   000   000  0000000  
    ###
        
    onWillReload: => @root = null
    onDidReload: =>
        if @base?
            @root = @createItem -1, @base.root, @
            @root.elem = @tree
            
    ###
    000  000000000  00000000  00     00
    000     000     000       000   000
    000     000     0000000   000000000
    000     000     000       000 0 000
    000     000     00000000  000   000
    ###
        
    newItem: (key, value, parent) -> new ViewItem key, value, parent        
                    
    ###
    00000000  000   000  00000000    0000000   000   000  0000000  
    000        000 000   000   000  000   000  0000  000  000   000
    0000000     00000    00000000   000000000  000 0 000  000   000
    000        000 000   000        000   000  000  0000  000   000
    00000000  000   000  000        000   000  000   000  0000000  
    ###

    onDidExpand:   (baseItem) =>  @update()
    onDidCollapse: (baseItem) =>  @update()
        
    ###
    000   000  00000000  000   000  0000000     0000000   000   000  000   000
    000  000   000        000 000   000   000  000   000  000 0 000  0000  000
    0000000    0000000     00000    000   000  000   000  000000000  000 0 000
    000  000   000          000     000   000  000   000  000   000  000  0000
    000   000  00000000     000     0000000     0000000   00     00  000   000
    ###
    
    selectedItem: () -> @root.children[parseInt(document.activeElement.id)]
    selectUp:   () -> @selectedItem().prevItem().select()
    selectDown: () -> @selectedItem().nextItem().select()
    
    onKeyDown: (event) =>
        e = document.activeElement
        keycode = keyname.keycode event
        switch keycode
            when 'up', 'down', 'left', 'right'
                item = @root.children[parseInt(e.id)]
                log e.id, item.indexInParent()
                item?["select#{_.capitalize(keycode)}"] event
                event.stopPropagation()
                event.preventDefault()
        
module.exports = View
