###
0000000     0000000   000000000   0000000 
000   000  000   000     000     000   000
000   000  000000000     000     000000000
000   000  000   000     000     000   000
0000000    000   000     000     000   000
###

Model = require './model'
find  = require './find'
log   = require './log'
path  = require 'path'
fs    = require 'fs'
_     = require 'lodash'

class DataModel extends Model

    load: (@filePath) =>
        @trigger 'willReload'
        @data = @parseString fs.readFileSync @filePath
        @root = @createItem -1, @data, @
        @root.fetch()
        @trigger 'didReload'

    parseString: (stringData) =>
        if path.extname(@filePath) == '.cson'
            require('CSON').parse stringData
        else
            JSON.parse stringData

    createItem: (key, data, parent) =>
        
        switch data.constructor.name
            when 'Array'
                item = super key, [], parent
                item.data = data
                item.unfetched = true
            when 'Object'
                item = super key, {}, parent
                item.data = data
                item.unfetched = true
            else
                item = super key, data, parent
        item
                        
    setValue: (item, value) =>
        item.parent.data[item.key] = value
        super

    fetchItem: (item) =>
        if item.unfetched
            if item.isObject()
                for key in Object.keys(item.data)
                    @createItem key, item.data[key], item
            else if item.isArray()
                for index in [0...item.data.length]
                    @createItem index, item.data[index], item
            delete item.unfetched

    findKeyValue: (key, value, item=@root) => find.keyValue item.data, key, value
    findKey:      (key,        item=@root) => find.key      item.data, key
    findValue:    (     value, item=@root) => find.value    item.data, value

    dataAt: (keyPath, item=@root) =>
        data = item.data
        while keyPath.length
            data = data[keyPath.shift()]
        data
        
module.exports = DataModel
