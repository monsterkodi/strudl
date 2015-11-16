###
000       0000000    0000000 
000      000   000  000      
000      000   000  000  0000
000      000   000  000   000
0000000   0000000    0000000 
###

bun = require 'bunyan'
fs  = require 'fs'
yan = bun.createLogger 
    name:    "model"
    level:   "debug"
    src:     false
    streams: [
        level: 'debug'
        path:  'model.log'
    ,
        level:  'debug'
        stream: process.stdout
    ]
    serializers: 
        model: (model) ->
            name:   model.name
            lastID: model.lastID
            base:   model.base?.name
        item: (item) ->
            id:    item.id
            key:   item.key
            model: item.model().name
            # value: item.value?.inspect? and item.value.inspect() or 'none'
    
log = -> 
    str = ""
    for arg in arguments
        str += "#{arg.inspect? and arg.inspect() or arg} "
    yan.debug str

module.exports = yan #yan.debug #log
