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
        @belowElem.items = []
        @aboveElem.items = []
        
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
        @space =
            above:  scroll.scrollTop
            height: scroll.clientHeight
            bottom: scroll.scrollTop + scroll.clientHeight
            below:  @tree.clientHeight - scroll.scrollTop - scroll.clientHeight
            total:  @tree.clientHeight
            line:   @root?.children[0]?.elem.clientHeight or 24

        # log "update", @space, @root
        # @root?.findFirst (i) =>
        #     if not i.nextItem()
        #         if i.elem.offsetTop + i.elem.clientHeight < @space.bottom
        #             item = @belowElem.items.shift()
        #             item.createElement()
        #             @belowElem.style.height = "#{@belowElem.clientHeight - @space.line}.px"
        #             false
        #         else
        #             true
        #     else
        #         false        
        
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
            @update()
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
        
        # if pe = parent.elem
        #     top = pe.offsetTop
        #     ph  = @space.line * (parent.children.length+1)
        #     if top + ph > @space.bottom
        #         @belowElem.style.height = "#{@belowElem.clientHeight + @space.line}.px"
        #         @belowElem.items.push item
        #         log 'below!', @belowElem.items.length
        #     else if top < @space.above - ph - @space.line
        #         # log 'above!', pe, top, ph
        #         @aboveElem.style.height = "#{@aboveElem.clientHeight + @space.line}.px"
        #     else 
        #         # log 'ok', top, ph
        #         item.createElement()
                
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

    onDidExpand: (baseItem) => 
        item = @itemMap[baseItem.id]
        @fetchItem item
        item.traverse (i) =>
            if i.isExpanded()
                @fetchItem i
                
        if not @selectedItem()
            item.children[0]?.select()
            
        @update()

    onDidCollapse: (baseItem) => 
        item = @itemMap[baseItem.id]
        item.traverse (i) -> i.removeElement() and false
        item.children = []
        item.unfetched = true
        
        @update()
        
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
