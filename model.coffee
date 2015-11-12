###
00     00   0000000   0000000    00000000  000    
000   000  000   000  000   000  000       000    
000000000  000   000  000   000  0000000   000    
000 0 000  000   000  000   000  000       000    
000   000   0000000   0000000    00000000  0000000
###

Events = require 'backbone-events-standalone'
Item   = require './item'
log    = require './log'

class Model
    
    Events.mixin Model.prototype
    
    constructor: (@name='model') -> 
        @item = {}
        
    setBase: (@base) =>
        for action in ['Reload', 'Remove', 'Insert', 'Change']
            @base.on "will#{action}", @["onWill#{action}"]
            @base.on "did#{action}",  @["onDid#{action}"]
                    
    onWillReload:   ()               => 
    onDidReload:    ()               => log 'onDidReload',    @
    onWillRemove:   (parent, items)  => log 'onWillRemove',   @, parent, items
    onDidRemove:    (parent)         => log 'onDidRemove',    @, parent
    onWillInsert:   (parent)         => log 'onWillInsert',   @, parent
    onDidInsert:    (parent, items)  => log 'onDidInsert',    @, parent, items
    onWillChange:   (item, newValue) => log 'onWillChange',   @, item, '>', newValue
    onDidChange:    (item, oldValue) => log 'onDidChange ',   @, item, '<', oldValue

    inspect: (depth) => "[:#{@name}:]"
            
    ###
    000  000000000  00000000  00     00
    000     000     000       000   000
    000     000     0000000   000000000
    000     000     000       000 0 000
    000     000     00000000  000   000
    ###
    
    newItem: (key, value, parent) => new Item key, value, parent
    createItem: (key, value, parent) =>
        item = @newItem key, value, parent
        @item[item.id] = item
        item
    
    itemAt: (keyPath) => @root.childAt keyPath
    
    ###
    000   000   0000000   000      000   000  00000000
    000   000  000   000  000      000   000  000     
     000 000   000000000  000      000   000  0000000 
       000     000   000  000      000   000  000     
        0      000   000  0000000   0000000   00000000
    ###
    
    setValue: (item, value) =>
        oldValue = item.value
        @trigger 'willChange', item, value
        item.value = value
        @trigger 'didChange', item, oldValue
                    
module.exports = Model
