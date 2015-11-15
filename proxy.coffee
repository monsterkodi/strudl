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
        @itemMap = {}
        if base instanceof Item
            @baseItem = base
            @name += ':' + @baseItem?.keyPath?().join?('.')
            @setBase @baseItem.model()
            @root = @createItem -1, @baseItem, @
            @expand @root
        else
            @setBase base if base?
        
    onWillReload:() => @root = null
    onDidReload:() => 
        if @base?
            @root = @createItem -1, @baseItem ? @base.root, @
            @expand @root
        
    onWillRemove:(baseItems) => 
        # log 'onWillRemove', @, baseItems
        for baseItem in baseItems
            item = @itemMap[baseItem.id]
            if item?
                log '-----------'
                item.parent.delChild item
        
    onDidInsert: (items)          => log 'onDidInsert',    @, items
    onDidChange: (item, oldValue) => log 'onDidChange ',   @, item, '<', oldValue
                
    createItem: (key, value, parent) -> 
        item = new ProxyItem key, value, parent
        item.id = @nextID()
        item.unfetched = true if item.isExpandable()
        @itemMap[value.id] = item
        item
        
    fetchItem: (item) ->
        if item.unfetched
            if item.isParent()
                for child in item.value.children
                    item.addChild @createItem child.key, child, item
            delete item.unfetched
                
    ###
    00000000  000   000  00000000    0000000   000   000  0000000  
    000        000 000   000   000  000   000  0000  000  000   000
    0000000     00000    00000000   000000000  000 0 000  000   000
    000        000 000   000        000   000  000  0000  000   000
    00000000  000   000  000        000   000  000   000  0000000  
    ###
    
    expand: (item, recursive=false) ->
        
        if item.isExpandable()
            
            if not item.expanded
                @trigger 'willExpand', item
                @fetchItem item
                item.expanded = true
                @trigger 'didExpand', item
                
            if recursive
                for child in item.children
                    @expand child, recursive
                
    collapse: (item, recursive=false) ->
        
        if item.isExpandable()
            
            if recursive
                for child in item.children
                    @collapse child, recursive
                
            if item.expanded
                @trigger 'willCollapse', item
                item.expanded = false
                @trigger 'didCollapse', item

    expandItems: (items) -> 
        for item in items
            @expand item

    expandLeaves: -> @expandItems @leafItems()

    collapseLeaves: (recursive=false) -> 
        for leaf in @leafItems()
            @collapse leaf, recursive
            
    collapseTop: (recursive=false) -> 
        for child in @root.children
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
            for child in item.children
                leafs.push.apply(leafs, @leafItems child)
            leafs
                    
module.exports = ProxyModel
