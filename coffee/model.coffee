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

    nextID: -> @lastID += 1
        
    inspect: (depth) -> "[:#{@name}:]"
            
    ###
    000  000000000  00000000  00     00
    000     000     000       000   000
    000     000     0000000   000000000
    000     000     000       000 0 000
    000     000     00000000  000   000
    ###
        
    getItem:(keyPath) -> @root.childAt keyPath
    itemAt: (keyPath) -> @root.childAt keyPath
    
    setValue: (item, value) ->
        if item.type == Item.valueType
            oldValue = item.value
            item.value = value
            @trigger 'didChange', item, oldValue
        
    remove: (item) ->
        @trigger 'willRemove', [item]
        item.parent.delChild item
        
    insert: (parent, key, value) ->
        @trigger 'didInsert', [parent.childAt [key]]
                            
module.exports = Model
