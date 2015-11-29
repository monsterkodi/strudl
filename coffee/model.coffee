###
00     00   0000000   0000000    00000000  000    
000   000  000   000  000   000  000       000    
000000000  000   000  000   000  0000000   000    
000 0 000  000   000  000   000  000       000    
000   000   0000000   0000000    00000000  0000000
###

Emitter = require 'events'
Item    = require './item'
log     = require './tools/log'

class Model extends Emitter
        
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
    
    ###
    00000000  0000000    000  000000000
    000       000   000  000     000   
    0000000   000   000  000     000   
    000       000   000  000     000   
    00000000  0000000    000     000   
    ###
    
    setValue: (item, value) ->
        if item.type == Item.valueType
            oldValue = item.value
            item.value = value
            @emit 'didChange', item, oldValue
        
    remove: (item) ->
        log 'will remove'
        @emit 'willRemove', [item]
        item.parent.delChild item
        @root.updateDescendants()
        
    insert: (parent, key, value) ->
        @root.updateDescendants()
        @emit 'didInsert', [parent.childAt [key]]
                            
module.exports = Model
