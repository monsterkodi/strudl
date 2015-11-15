###
0000000     0000000   000000000   0000000 
000   000  000   000     000     000   000
000   000  000000000     000     000000000
000   000  000   000     000     000   000
0000000    000   000     000     000   000
###

Item    = require './item'
profile = require './profile'
Model   = require './model'
log     = require './log'
path    = require 'path'
fs      = require 'fs'
_       = require 'lodash'

class DataModel extends Model

    load: (@filePath) ->
        @trigger 'willReload'
        @data = @parseString fs.readFileSync @filePath
        profile "create tree"
        @root = @createItem -1, @data, @
        log "#{Item.ID} items"
        @trigger 'didReload'

    parseString: (stringData) ->
        if path.extname(@filePath) == '.cson'
            require('CSON').parse stringData
        else
            JSON.parse stringData

    createItem: (key, data, parent) -> 
        
        item = new Item key, data, parent
        
        switch item.type
            when Item.arrayType
                for index in [0...data.length]
                    item.children.push @createItem index, data[index], item
            when Item.objectType
                for key in Object.keys(data)
                    item.children.push @createItem key, data[key], item
        
        item
                        
    setValue: (item, value) ->
        item.parent.value[item.key] = value
        super

    findKeyValue: (key, value, item=@root) -> item.traverse (k,v) => @match(k, key) and @match(v, value)
    findValue:    (     value, item=@root) -> item.traverse (k,v) => @match(v, value)
    findKey:      (key,        item=@root) -> item.traverse (k,v) => @match(k, key)
        
    match: (a,b) ->
        if _.isString(a) and _.isString(b) and b.indexOf('*') >= 0
            p = _.clone(b)
            p = p.replace /\*/g, '.*'
            p = "^"+p+"$"
            a.match(new RegExp(p))?.length
        else
            a == b

        
module.exports = DataModel
