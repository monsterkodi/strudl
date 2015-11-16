###
000   000  000  00000000  000   000
000   000  000  000       000 0 000
 000 000   000  0000000   000000000
   000     000  000       000   000
    0      000  00000000  00     00
###

log      = require './log'
Model    = require './model'
Proxy    = require './proxy'
Item     = require './item'
ViewItem = require './viewitem'

class View extends Proxy
        
    constructor: (base, @tree) -> 
        super base, 'view', @tree
        
    setBase: (base) ->
        super base
        @base.on "didExpand",   @onDidExpand
        @base.on "didCollapse", @onDidCollapse

    onDidExpand: (baseItem) => 
        item = @itemMap[baseItem.id]
        @fetchItem item

    onDidCollapse: (baseItem) => 
        item = @itemMap[baseItem.id]
        log.debug 'didCollapse', item.id
        item.traverse (i) -> i.removeElement()
        item.children = []
        # while item.children.length
        #     item.delChild item.children[0]
        item.unfetched = true
        
    onWillReload: => @root = null
    onDidReload: =>
        if @base?
            log.debug model:@, 'onDidReload'
            @root = @createItem -1, @base.root, @
            @root.elem = @tree
        
    newItem: (key, value, parent) -> new ViewItem key, value, parent        
        
    createItem: (key, value, parent) -> 
        log.debug 'createItem', key
        item = super
        item.createElement()
        item
        
module.exports = View
