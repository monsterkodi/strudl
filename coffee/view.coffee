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
        @aboveElem = $('above')
        @belowElem = $('below')
        
    setBase: (base) ->
        super base
        @base.on "didExpand",   @onDidExpand
        @base.on "didCollapse", @onDidCollapse

    ###
    00000000   00000000   0000000  000  0000000  00000000
    000   000  000       000       000     000   000     
    0000000    0000000   0000000   000    000    0000000 
    000   000  000            000  000   000     000     
    000   000  00000000  0000000   000  0000000  00000000
    ###

    onScroll: (event) => @update()
        
    update: ->
        scroll = @tree.parentElement

        line     = @root?.children[0]?.elem.clientHeight or 24
        numlines = parseInt(scroll.clientHeight / line)
        total    = @base.root.numVisible * line
        height   = line * numlines
        above    = Math.min(@base.root.numVisible - numlines, parseInt(scroll.scrollTop / line)) * line
        bottom   = above + height
        first    = parseInt(above / line)
        last     = first + numlines
        below    = Math.max(0, total - above - height)
            
        @root.children = []
        @tree.innerHTML = "" # proper destruction needed?

        @aboveElem.style.height = "#{above}.px"
        @belowElem.style.height = "#{below}.px"
                                        
        for i in [first...last]
            baseItem = @base.visibleAtIndex i
            @createItem baseItem.key, baseItem, @root
                                
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
        
    createItem: (key, value, parent) -> 
        item = super
        item.createElement()                
        item
        
    selectedItem: -> @getItem document.activeElement?.id
    
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
    
    onKeyDown: (event) =>
        e   = document.activeElement
        keycode = keyname.keycode event
        switch keycode
            when 'up', 'down', 'left', 'right'
                item = @getItem e.id
                item?["select#{_.capitalize(keycode)}"] event
                event.stopPropagation()
                event.preventDefault()
        
module.exports = View
