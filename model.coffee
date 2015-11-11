###
00     00   0000000   0000000    00000000  000    
000   000  000   000  000   000  000       000    
000000000  000   000  000   000  0000000   000    
000 0 000  000   000  000   000  000       000    
000   000   0000000   0000000    00000000  0000000
###

log    = require './log'
Events = require 'backbone-events-standalone'
Item   = require './item'

class Model
    
    Events.mixin Model.prototype
    
    constructor: (@name='model') -> 
        @item = {}
        
    setBase: (@base) =>
        for action in ['Reload', 'Expand', 'Collapse', 'Remove', 'Insert', 'Change']
            @base.on "will#{action}", @["onWill#{action}"]
            @base.on "did#{action}", @["onDid#{action}"]
        
    onWillReload:   ()               => log 'onWillReload',   @
    onDidReload:    ()               => log 'onDidReload',    @
    onWillExpand:   (item)           => log 'onWillExpand',   @, item
    onDidExpand:    (item)           => log 'onDidExpand',    @, item
    onWillCollapse: (item)           => log 'onWillCollapse', @, item
    onDidCollapse:  (item)           => log 'onDidCollapse',  @, item
    onWillRemove:   (parent, items)  => log 'onWillRemove',   @, parent, items
    onDidRemove:    (parent)         => log 'onDidRemove',    @, parent
    onWillInsert:   (parent)         => log 'onWillInsert',   @, parent
    onDidInsert:    (parent, items)  => log 'onDidInsert',    @, parent, items
    onWillChange:   (item, newValue) => log 'onWillChange',   @, item, '>', newValue
    onDidChange:    (item, oldValue) => log 'onDidChange ',   @, item, '<', oldValue

    inspect: (depth) => "[:#{@name}:]"
    get: (keyPath) => @root.get keyPath
    
    fecthItem: (item) =>
    
    expand: (item) =>
        
        if item.isExpandable()
            if not item.expanded
                @trigger 'willExpand', item
                @fetchItem item
                item.expanded = true
                @trigger 'didExpand', item
                
    collapse: (item, recursive=false) =>
        
        if item.isExpandable()
            
            if recursive
                for child in item.children()
                    @collapse child, recursive
                
            if item != @root
                @trigger 'willCollapse', item
                item.expanded = false
                @trigger 'didCollapse', item
            else
                for child in item.children()
                    @trigger 'willCollapse', child
                    child.expanded = false
                    @trigger 'didCollapse', child

    expandAll: =>
        for leaf in @leafItems()
            @expand leaf
            
    collapseAll: => 
            for child in @root.children()
                @collapse child, true
    
    isLeaf: (item) =>
        if item.isExpandable() 
            not item.expanded 
        else 
            true
        
    leafItems: (item=@root) =>
        if @isLeaf item
            [item]
        else
            leafs = []
            for child in item.children()
                leafs.push.apply(leafs, @leafItems child)
            leafs
    
    setValue: (item, value) =>
        oldValue = item.value
        @trigger 'willChange', item, value
        item.value = value
        @trigger 'didChange', item, oldValue
    
    createItem: (key, value, parent) =>
        item = new Item @, key, value, parent
        @item[item.id] = item
        item
                
module.exports = Model
