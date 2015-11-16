###
000       0000000    0000000 
000      000   000  000      
000      000   000  000  0000
000      000   000  000   000
0000000   0000000    0000000 
###

log = (require 'bunyan').createLogger 
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
    
module.exports = -> log.debug.apply log, arguments
