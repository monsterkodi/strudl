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
        
    setBase: (base) ->
        super base
        @base.on "didExpand",   @onDidExpand
        @base.on "didCollapse", @onDidCollapse

    onDidExpand: (baseItem) => 
        item = @itemMap[baseItem.id]
        @fetchItem item
        item.traverse (i) =>
            if i.isExpanded()
                @fetchItem i

    onDidCollapse: (baseItem) => 
        item = @itemMap[baseItem.id]
        item.traverse (i) -> i.removeElement()
        item.children = []
        item.unfetched = true
        
    onWillReload: => @root = null
    onDidReload: =>
        if @base?
            log model:@, 'onDidReload'
            @root = @createItem -1, @base.root, @
            @root.elem = @tree
        
    newItem: (key, value, parent) -> new ViewItem key, value, parent        
        
    createItem: (key, value, parent) -> 
        item = super
        item.createElement()
        item
        
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
