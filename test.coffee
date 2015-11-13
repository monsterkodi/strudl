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
    log data.root
    for vw in v
        log ''
        log vw.root
    profile ""

log process.argv[1], process.mainModule == module

# for file in ["darwin.cson", "test.json", "config.cson", "fish.cson", "swift.cson"]
# for file in ["test.cson"]
if true
    for file in ["data.json"]
        filePath = "data/#{file}"
        log "loading #{filePath} ..."
        profile "load"
        data.load filePath

        # profile "find ref_uid"
        # found = data.findKey 'ref_uid'
        # log "#{found.length} items"

        profile "find uid"
        found = data.findKey 'uid'
        
        for path in found
            log chalk.gray.bold(path.join('.')) + chalk.gray(': ') + chalk.yellow.bold(data.dataAt(path))

        log "#{found.length} items"
        profile ''
        # dump(filePath)

if false
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

        profile "find"
        found = data.findKeyValue 'rarity', 'Rare'
        
        profile "find"
        found = data.findValue 'Forest'

        profile ""
        dump(filePath)
