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
profile = require './profile'
ViewItem = require './viewitem'
keyname  = require './keyname'

class View extends Proxy
        
    constructor: (base, @tree) -> 
        super base, 'view', @tree
        @tree.addEventListener 'keydown', @onKeyDown
        @tree.parentElement.addEventListener 'scroll',  @onScroll
        @topIndex = 0
        
    setBase: (base) ->
        super base
        @base.on "didExpand",   @onDidExpand
        @base.on "didCollapse", @onDidCollapse
        @base.on "didLayout",   @onDidLayout

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

    onScroll: (event) => 
        scroll   = @tree.parentElement
        line     = @root?.children[0]?.elem.clientHeight or 24
        topindex = parseInt(scroll.scrollTop / line)
        if topindex != @topIndex
            @update()
            @topIndex = topindex

    ###
    000   000  00000000   0000000     0000000   000000000  00000000
    000   000  000   000  000   000  000   000     000     000     
    000   000  00000000   000   000  000000000     000     0000000 
    000   000  000        000   000  000   000     000     000     
     0000000   000        0000000    000   000     000     00000000
    ###
        
    update: ->
        doProfile = false
        profile "update #{@root.value.numVisible}" if doProfile
        scroll   = @tree.parentElement
        sheight  = scroll.clientHeight

        selitem  = @selectedItem()
        selindex = selitem?.value.visibleIndex
        selitem?.deselect()

        visible  = @base.root.numVisible
        line     = @root?.children[0]?.elem.clientHeight or 24
        numlines = parseInt(sheight / line)
        total    = visible * line
        topindex = parseInt(scroll.scrollTop / line)
        botindex = topindex + numlines
        n = 0
        first    = Math.max(0, topindex - n * numlines)
        last     = Math.min(first + (1 + 2 * n) * numlines, visible)
                    
        @root.children = []
        @root.keyIndex = {}
        @tree.innerHTML = "" # proper destruction needed?
                                        
        for i in [first..last]
            baseItem = @base.visibleItems[i]
            @root.keyIndex[baseItem.key] = @root.children.length
            item = @createItem baseItem.key, baseItem, @root
            @root.children.push item
            item.createElement()     
            item.elem.style.top = "#{i*line}.px"  
            if baseItem.visibleIndex == selindex
                if selindex >= topindex and selindex <= botindex
                    item.select()
                                
        @tree.style.height = "#{total}.px"
        profile "" if doProfile
                          
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

    onDidExpand:   (baseItem) => 
    onDidCollapse: (baseItem) => 
    onDidLayout:   (baseItem) => @update()
        
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
                item?["select#{_.capitalize(keycode)}"] event
                event.stopPropagation()
                event.preventDefault()
        
module.exports = View
