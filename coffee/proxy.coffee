###
00000000   00000000    0000000   000   000  000   000
000   000  000   000  000   000   000 000    000 000 
00000000   0000000    000   000    00000      00000  
000        000   000  000   000   000 000      000   
000        000   000   0000000   000   000     000   
###

log       = require './log'
Model     = require './model'
ProxyItem = require './proxyitem'
Item      = require './item'

ID=0

class Proxy extends Model
        
    constructor: (base, name='proxy') -> 
        super name + (ID += 1)
        @itemMap = {}
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
    
    numVisible: (item=@root) -> item.numVisible()
        
    onWillReload:() => 
        @trigger "willReload"
        @root = null
        
    onDidReload: () => 
        if @base?
            @root = @createItem -1, @baseItem ? @base.root, @
            @trigger "didReload"
            @expand @root
        
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

    visibleAtIndex: (i) -> @root.visibleAtIndex i
                    
module.exports = Proxy
