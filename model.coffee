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
    
    constructor: (@name='model') -> @lastID = -1
        
    setBase: (@base) ->
        @base.on "willReload", @onWillReload
        @base.on "didReload",  @onDidReload
        @base.on "willRemove", @onWillRemove
        @base.on "didInsert",  @onDidInsert
        @base.on "didChange",  @onDidChange
                    
    onWillReload:   ()               => 
    onDidReload:    ()               => log 'onDidReload',    @
    onWillRemove:   (items)          => log 'onWillRemove',   @, items
    onDidInsert:    (items)          => log 'onDidInsert',    @, items
    onDidChange:    (item, oldValue) => log 'onDidChange ',   @, item, '<', oldValue

    inspect: (depth) -> "[:#{@name}:]"
            
    ###
    000  000000000  00000000  00     00
    000     000     000       000   000
    000     000     0000000   000000000
    000     000     000       000 0 000
    000     000     00000000  000   000
    ###
        
    itemAt: (keyPath) -> @root.childAt keyPath
    nextID: () -> @lastID += 1
    
    ###
    000   000   0000000   000      000   000  00000000
    000   000  000   000  000      000   000  000     
     000 000   000000000  000      000   000  0000000 
       000     000   000  000      000   000  000     
        0      000   000  0000000   0000000   00000000
    ###
    
    setValue: (item, value) ->
        if item.type == Item.valueType
            oldValue = item.value
            item.value = value
            @trigger 'didChange', item, oldValue
        
    remove: (item) ->
        @trigger 'willRemove', [item]
        item.parent.delChild item
                    
module.exports = Model
