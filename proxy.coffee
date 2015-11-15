###
00000000   00000000    0000000   000   000  000   000  00     00   0000000   0000000    00000000  000    
000   000  000   000  000   000   000 000    000 000   000   000  000   000  000   000  000       000    
00000000   0000000    000   000    00000      00000    000000000  000   000  000   000  0000000   000    
000        000   000  000   000   000 000      000     000 0 000  000   000  000   000  000       000    
000        000   000   0000000   000   000     000     000   000   0000000   0000000    00000000  0000000
###

log       = require './log'
Model     = require './model'
ProxyItem = require './proxyitem'
Item      = require './item'

ID=0

class ProxyModel extends Model
        
    constructor: (base) -> 
        super 'proxy' + (ID += 1)
        if base instanceof Item
            @baseItem = base
            @name += ':' + @baseItem?.keyPath?().join?('.')
            @setBase @baseItem.model()
            @root = @createItem -1, @baseItem, @
            @expand @root            
        else
            @setBase base if base?
        
    onWillReload:() -> @root = null
    onDidReload:() -> 
        return if not @base?
        @root = @createItem -1, @base.root, @
        @expand @root
        
    onWillRemove:   (parent, items)  -> log 'onWillRemove',   @, parent, items
    onDidRemove:    (parent)         -> log 'onDidRemove',    @, parent
    onWillInsert:   (parent)         -> log 'onWillInsert',   @, parent
    onDidInsert:    (parent, items)  -> log 'onDidInsert',    @, parent, items
    onWillChange:   (item, newValue) -> log 'onWillChange',   @, item, '>', newValue
    onDidChange:    (item, oldValue) -> log 'onDidChange ',   @, item, '<', oldValue
                
    newItem: (key, value, parent) -> new ProxyItem key, value, parent
        
    createItem: (key, baseItem, parent) ->
        
        switch baseItem.typeName()
            when 'Array'
                item = super key, [], parent
                item.unfetched = true
            when 'Object'
                item = super key, {}, parent
                item.unfetched = true
            else
                item = super key, baseItem, parent
        item.baseItem = baseItem
        item
        
    fetchItem: (item) ->
        if item.unfetched
            item.baseItem.fetch()
            if item.isParent()
                for child in item.baseItem.children
                # for key in item.baseItem.keys()
                    @createItem child.key, child, item
            delete item.unfetched
                
    ###
    00000000  000   000  00000000    0000000   000   000  0000000  
    000        000 000   000   000  000   000  0000  000  000   000
    0000000     00000    00000000   000000000  000 0 000  000   000
    000        000 000   000        000   000  000  0000  000   000
    00000000  000   000  000        000   000  000   000  0000000  
    ###
    
    expand: (item) ->
        if item.isExpandable()
            if not item.expanded
                @trigger 'willExpand', item
                item.fetch()
                item.expanded = true
                @trigger 'didExpand', item
                
    collapse: (item, recursive=false) ->
        
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

    expandItems: (items) -> 
        for item in items
            @expand item

    expandLeaves: -> @expandItems @leafItems()

    collapseLeaves: (recursive=false) -> 
        for leaf in @leafItems()
            @collapse leaf, recursive
            
    collapseTop: (recursive=false) -> 
        for child in @root.children()
            @collapse child, recursive
    
    isLeaf: (item) ->
        if item.isExpandable() 
            not item.expanded 
        else 
            true
        
    leafItems: (item=@root) ->
        if @isLeaf item
            [item]
        else
            leafs = []
            for child in item.children()
                leafs.push.apply(leafs, @leafItems child)
            leafs
                    
module.exports = ProxyModel
