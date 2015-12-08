###
0000000     0000000   000000000   0000000 
000   000  000   000     000     000   000
000   000  000000000     000     000000000
000   000  000   000     000     000   000
0000000    000   000     000     000   000
###

Model   = require './model'
Item    = require './item'
profile = require './tools/profile'
log     = require './tools/log'
path    = require 'path'
sds     = require 'sds'
fs      = require 'fs'
_       = require 'lodash'

class DataModel extends Model

    load: (@filePath) ->
        dbg @filePath
        @emit 'willReload'
        if path.extname(@filePath) in sds.extnames
            @data = sds.load @filePath

        profile "create tree" 
        @root = @createItem -1, @data, @
        log "tree created"
        @root.updateDescendants()
        @dataRoot = @root
        profile ""
        log "#{@lastID} items"
        @emit 'didReload'

    setFilter: (path, value) ->
        @emit 'willReload'
        if path and value
            @filtered = @findPathValue path, value
        else if path
            @filtered = @findPath path
        else if value
            @filtered = @findValue value
        else
            @filtered = null
            @root = @dataRoot
            @emit 'didReload'
            return
            
        f = {}
        for i in @filtered
            f[i.keyPath().join '►'] = i.value
        @root = @createItem -1, f, @
        @root.updateDescendants()
        @emit 'didReload'

    ###
    000  000000000  00000000  00     00
    000     000     000       000   000
    000     000     0000000   000000000
    000     000     000       000 0 000
    000     000     00000000  000   000
    ###

    createItem: (key, data, parent) -> 
        
        item = new Item key, data, parent
        item.id = @nextID()
        if item.id > 3000000 then return item
        switch item.type
            when Item.arrayType
                for index in [0...data.length]
                    item.addChild @createItem index, data[index], item
            when Item.objectType
                for key in Object.keys(data)
                    item.addChild @createItem key, data[key], item
        item
        
    ###
    00000000  0000000    000  000000000
    000       000   000  000     000   
    0000000   000   000  000     000   
    000       000   000  000     000   
    00000000  0000000    000     000   
    ###
        
    insert: (parent, key, value) ->
        parent.addChild @createItem key, value, parent
        super
                                
    setValue: (item, value) ->
        item.parent.value[item.key] = value
        super

    ###
    00000000  000  000   000  0000000  
    000       000  0000  000  000   000
    000000    000  000 0 000  000   000
    000       000  000  0000  000   000
    000       000  000   000  0000000  
    ###

    reg: (s) -> sds.regexp s

    findKeyValue: (key, val, item=@dataRoot) -> 
        keyReg = @reg key 
        valReg = @reg val 
        item.traverse (i) => @match(i.key, keyReg) and @match(i.getValue(), valReg)
    findValue:    (     val, item=@dataRoot) -> 
        valReg = @reg val         
        item.traverse (i) => @match(i.getValue(), valReg)
    findKey:      (key,      item=@dataRoot) -> 
        keyReg = @reg key 
        item.traverse (i) => @match(i.key, keyReg)
    findPath:     (path,     item=@dataRoot) -> 
        pthReg = @reg path
        item.traverse (i) => @matchPath(i.keyPath(), pthReg)
    findPathValue:(path, val,item=@dataRoot) -> 
        pthReg = @reg path
        valReg = @reg val         
        item.traverse (i) => @matchPath(i.keyPath(), pthReg) and @match(i.getValue(), valReg)
    
    matchPath: (a, r) -> @match a.join('.'), r
        
    match: (a,r) ->
        if not _.isArray(a)
            sa = String a
            sa.match(r)?.length
        else
            false

module.exports = DataModel
