###
0000000     0000000   000000000   0000000 
000   000  000   000     000     000   000
000   000  000000000     000     000000000
000   000  000   000     000     000   000
0000000    000   000     000     000   000
###

Model = require './model'
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

    findData: (item, what, func, keyPath=[], result=[]) =>
        switch item.constructor.name
            when "Array"
                for i in [0...item.length]
                    v = item[i]
                    if v.constructor.name in ["Array", "Object"]
                        keyPath.push i
                        @findData v, what, func, keyPath, result
                        keyPath.pop()
            when "Object"
                for k,v of item
                    if func k,v
                        # log 'found', keyPath, item
                        return keyPath if what == 'first'
                        result.push _.clone(keyPath, true) if what == 'all'
                    if v.constructor.name in ["Array", "Object"]
                        keyPath.push k
                        @findData v, what, func, keyPath, result
                        keyPath.pop()
        return result

    find: (key, value, below=@root) =>
        @findData below.data, 'all', (k,v) => (k == key) and (not value? or v == value)

    dataAt: (keyPath, item=@root) =>
        data = item.data
        while keyPath.length
            data = data[keyPath.shift()]
        data
        
module.exports = DataModel
