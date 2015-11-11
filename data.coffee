###
0000000     0000000   000000000   0000000 
000   000  000   000     000     000   000
000   000  000000000     000     000000000
000   000  000   000     000     000   000
0000000    000   000     000     000   000
###

Model = require './model'
path = require 'path'

DataModel extends Model

    load: (@filePath) =>
        
        @trigger 'willReload'
        @data = @parseString fs.readFileSync @filePath
        @root = @createItem -1, @data
        @root.expand()
        @trigger 'didReload'

    parseString: (stringData) => 
        if path.extname(filePath) == '.cson'
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



module.exports = DataModel
