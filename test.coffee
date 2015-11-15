###
000000000  00000000   0000000  000000000
   000     000       000          000   
   000     0000000   0000000      000   
   000     000            000     000   
   000     00000000  0000000      000   
###

Proxy   = require './proxy'
Data    = require './data'
log     = require './log'
profile = require './profile'
chalk   = require 'chalk'

data = new Data()
v = []
v.push new Proxy data
# v.push new Proxy data

dump = (msg) ->
    profile "dump"
    log '-------------------------------- ' + msg
    # log data.root
    for vw in v
        log ''
        log vw.root
    profile ""

log process.argv[1], process.mainModule == module

# for file in ["darwin.cson", "test.json", "config.cson", "fish.cson", "swift.cson"]

# coffee find.coffee data/data.json -k name -f "#{v}" | sort | uniq -c | sort 

if true
    for file in ["data.json"]
        filePath = "data/#{file}"
        log "loading #{filePath} ..."
        profile "load"
        data.load filePath

        profile "find *uid"
        found = data.findKey '*uid'
        log "#{found.length} items"

        profile "find 666"
        found = data.findValue '*666*'
        log "#{found.length} items"

        profile "find checksum 2286196866"
        found = data.findKeyValue 'checksum', 2286196866
        log "#{found.length} items"

        profile "find key *"
        found = data.findKey '*'
        log "#{found.length} items"

        profile ''
        dump(filePath)

if true
    for file in ["cards.json"]
        filePath = "data/#{file}"
        log "loading #{filePath} ..."
        profile "load"
        data.load filePath

        profile "find"
        found = data.findKeyValue 'rarity', 'Mythic Rare'
        # for path in found
        #     log path.join('.'), data.dataAt(path)
        
        profile "find"
        found = data.findKey 'rarity'
        log "#{found.length} items"

        profile "find"
        found = data.findKeyValue 'rarity', 'Rare'
        log "#{found.length} items"
        
        profile "find"
        found = data.findValue 'Forest'
        log "#{found.length} items"

        profile ""
        dump(filePath)
