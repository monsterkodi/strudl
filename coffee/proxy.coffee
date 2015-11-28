###
00000000   00000000    0000000   000   000  000   000
000   000  000   000  000   000   000 000    000 000 
00000000   0000000    000   000    00000      00000  
000        000   000  000   000   000 000      000   
000        000   000   0000000   000   000     000   
###

log       = require './tools/log'
Model     = require './model'
profile   = require './tools/profile'
ProxyItem = require './proxyitem'
Item      = require './item'

ID=0

class Proxy extends Model
        
    constructor: (base, name='proxy') -> 
        super name + (ID += 1)
        @itemMap = {}
        @visibleItems = []
        if base instanceof Item
            @baseItem = base
            @name += ':' + @baseItem?.keyPath?().join?('.')
            @setBase @baseItem.model()
            @root = @createItem -1, @baseItem, @
            @expand @root
        else
            @setBase base if base?
        
    setBase: (@base) ->
        @base.on "willReload", @onWillReload
        @base.on "didReload",  @onDidReload
        @base.on "willRemove", @onWillRemove
        @base.on "didInsert",  @onDidInsert
        @base.on "didChange",  @onDidChange        
            
    onWillReload:() => 
        @trigger "willReload"
        @root = null
        
    onDidReload: () => 
        if @base?
            @root = @createItem -1, @baseItem ? @base.root, @
            @trigger "didReload"
            @expand @root
                
    newItem: (key, value, parent) -> new ProxyItem key, value, parent
                
    createItem: (key, value, parent) -> 
        item = @newItem key, value, parent
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
            
    layout: (item) ->
        @root.updateCounters()
        @trigger 'didLayout', item
        
    ###
    00000000  0000000    000  000000000
    000       000   000  000     000   
    0000000   000   000  000     000   
    000       000   000  000     000   
    00000000  0000000    000     000   
    ###
    
    onWillRemove: (baseItems) =>
        for baseItem in baseItems
            item = @itemMap[baseItem.id]
            if item?
                @trigger "willRemove", item
                item.parent.delChild item

    onDidInsert: (baseItems) => 
        for baseItem in baseItems
            parent = @itemMap[baseItem.parent.id]
            if parent? and (not parent.unfetched)
                item = @createItem baseItem.key, baseItem, parent
                parent.addChild item
                @trigger "didInsert", item
        
    onDidChange: (baseItem, oldValue) => 
        item = @itemMap[baseItem.id]
        if item?
            @trigger "didChange", item, oldValue    
                        
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
                @fetchItem item
                item.expanded = true
                
            if recursive
                for child in item.children
                    @expand child, recursive + 1
            
            if typeof(recursive) == 'boolean'
                @layout item
                
    collapse: (item, recursive=false) ->
        
        if item.isExpandable()
            
            if recursive
                for child in item.children
                    @collapse child, recursive + 1
                
            if item.expanded
                item.expanded = false
                
            if typeof(recursive) == 'boolean'
                @layout item

    expandItems: (items, recursive=false) -> 
        for item in items
            @expand item, recursive and 1 or 0
        @layout items[0]

    collapseItems: (items, recursive=false) -> 
        for item in items
            @collapse item, recursive and 1 or 0
        @layout items[0]

    expandTop:      (recursive=false) -> @expandItems @root.children, recursive
    collapseTop:    (recursive=false) -> @collapseItems @root.children, recursive
    collapseLeaves: (recursive=false) -> @collapseItems @leafItems(), recursive
    expandLeaves: -> @expandItems @leafItems()
    
    ###
    000      00000000   0000000   00000000
    000      000       000   000  000     
    000      0000000   000000000  000000  
    000      000       000   000  000     
    0000000  00000000  000   000  000     
    ###
    
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
                    
module.exports = Proxy
