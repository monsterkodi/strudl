###
      000   0000000   0000000   000   000
      000  000       000   000  0000  000
      000  0000000   000   000  000 0 000
000   000       000  000   000  000  0000
 0000000   0000000    0000000   000   000
###

Model = require './model'
log   = require './log'
fs    = require 'fs'

class JSONModel extends Model

    constructor: (name='json') -> super
        
    load: (@filePath) =>
        
        @trigger 'willReload'
        @json = JSON.parse fs.readFileSync @filePath
        @root = @createItem -1, @json
        @root.expand()
        @trigger 'didReload'
                            
    createItem: (key, json, parent) =>
        
        switch json.constructor.name
            when 'Array'
                item = super key, [], parent
                item.json = json
                item.fetched = false
            when 'Object'
                item = super key, {}, parent
                item.json = json
                item.fetched = false
            else
                item = super key, json, parent
        item
                        
    setValue: (item, value) =>
        item.parent.json[item.key] = value
        super

    fetchItem: (item) =>
        if not item.fetched
            if item.isObject()
                for key in Object.keys(item.json)
                    @createItem key, item.json[key], item
            else if item.isArray()
                for index in [0...item.json.length]
                    @createItem index, item.json[index], item
            item.fetched = true
        
module.exports = JSONModel
