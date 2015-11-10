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
        @base.on 'willReload', @onWillReload
        @base.on 'didReload' , @onDidReload
        @base.on 'willRemove', @onWillRemove
        @base.on 'didRemove' , @onDidRemove
        @base.on 'willInsert', @onWillInsert
        @base.on 'didInsert' , @onDidInsert
        @base.on 'willChange', @onWillChange
        @base.on 'didChange' , @onDidChange
        
    onWillReload: ()               => log 'onWillReload', @
    onDidReload:  ()               => log 'onDidReload',  @
    onWillRemove: (parent, items)  => log 'onWillRemove', @, parent, items
    onDidRemove:  (parent)         => log 'onDidRemove',  @, parent
    onWillInsert: (parent)         => log 'onWillInsert', @, parent
    onDidInsert:  (parent, items)  => log 'onDidInsert',  @, parent, items
    onWillChange: (item, newValue) => log 'onWillChange', @, item, '>', newValue
    onDidChange:  (item, oldValue) => log 'onDidChange ', @, item, '<', oldValue

    inspect: (depth) => "[:#{@name}:]"
    get: (keyPath) => @root.get keyPath
    
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
