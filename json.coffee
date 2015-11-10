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
        log @root
        @trigger 'didReload'
                            
    createItem: (key, json, parent) =>
        
        switch json.constructor.name
            when 'Array'
                item = super key, [], parent
                item.json = json
                for index in [0...json.length]
                    @createItem index, json[index], item
            when 'Object'
                item = super key, {}, parent
                item.json = json
                for key in Object.keys(json)
                    @createItem key, json[key], item
            else
                item = super key, json, parent
        item
                
    setValue: (item, value) =>
        item.parent.json[item.key] = value
        super
        
        
module.exports = JSONModel
