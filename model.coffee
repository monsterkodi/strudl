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
        @base.on 'willReload',   @onWillReload
        @base.on 'didReload' ,   @onDidReload
        @base.on 'willExpand',   @onWillExpand
        @base.on 'didExpand' ,   @onDidExpand
        @base.on 'willCollapse', @onWillCollapse
        @base.on 'didCollapse' , @onDidCollapse
        @base.on 'willRemove',   @onWillRemove
        @base.on 'didRemove' ,   @onDidRemove
        @base.on 'willInsert',   @onWillInsert
        @base.on 'didInsert' ,   @onDidInsert
        @base.on 'willChange',   @onWillChange
        @base.on 'didChange' ,   @onDidChange
        
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
    
    expand: (item, recursive=false) =>
        
        if item.isExpandable()
            if not item.expanded
                @trigger 'willExpand', item
                @fetchItem item
                item.expanded = true
                @trigger 'didExpand', item
            
            if recursive
                expandChildren = () =>
                    for child in item.children()
                        @expand child, recursive
                    if item == @root
                        log 'root expanded'
                setTimeout expandChildren, 1
                
    collapse: (item, recursive=false) =>
        
        if item.isExpandable()
            if recursive
                for child in item.children()
                    @collapse child, recursive
                
            if item != @root
                item.expanded = false
            else
                for child in item.children()
                    child.expanded = false

    expandAll: => @expand @root, true
    collapseAll: => 
            for child in @root.children()
                @collapse child, true
    
    
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
