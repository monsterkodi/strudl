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
fs      = require 'fs'
_       = require 'lodash'

class DataModel extends Model

    load: (@filePath) ->
        @trigger 'willReload'
        if path.extname(@filePath) == '.plist'
            @data = require('simple-plist').readFileSync @filePath
        else
            @data = @parseString fs.readFileSync @filePath
        profile "create tree"
        @root = @createItem -1, @data, @
        @root.updateDescendants()
        profile ""
        log "#{@lastID} items"
        @trigger 'didReload'

    parseString: (stringData) ->
        switch path.extname(@filePath) 
            when '.cson'
                require('CSON').parse stringData
            else
                JSON.parse stringData

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

    findKeyValue: (key, value, item=@root) -> item.traverse (i) => @match(i.key, key) and @match(i.getValue(), value)
    findValue:    (     value, item=@root) -> item.traverse (i) => @match(i.getValue(), value)
    findKey:      (key,        item=@root) -> item.traverse (i) => @match(i.key, key)
        
    match: (a,b) ->
        if _.isString(a) and _.isString(b) and b.indexOf('*') >= 0
            p = _.clone(b)
            p = p.replace /\*/g, '.*'
            p = "^"+p+"$"
            a.match(new RegExp(p))?.length
        else
            a == b

        
module.exports = DataModel
