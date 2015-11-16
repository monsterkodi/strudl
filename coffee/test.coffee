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

dump = (msg) ->
    profile "dump"
    log '-------------------------------- ' + msg
    # log data.root
    for vw in v
        log ''
        console.log vw.root
    profile ""

if true
    for file in ["test.json"]
        filePath = "data/#{file}"
        log "loading #{filePath} ..."
        profile "load"
        data.load filePath
        profile ''
        console.log data.root
        
        v.push new Proxy data.itemAt '3'
        v.push new Proxy data.itemAt '3'        
        v[0].expandLeaves()
        v[0].expandLeaves()
        v[1].expandLeaves()
        v[1].expandLeaves()
        v[1].root.collapse(true)
        
        data.itemAt('3.empty').insert 0, 666
        data.itemAt('3.empty').insert 0, 999
        data.itemAt('3.obj').insert 'a', 0
        data.itemAt('3.obj').insert 'b', 1
        data.itemAt('3.obj').insert 'c', []
        v[0].expandLeaves()
        v[0].expandLeaves()
        v[0].expandLeaves()
        data.itemAt('3.obj.c').insert '0', {'y': 2, 'z': 3}
        v[0].expandLeaves()
        v[0].expandLeaves()
        data.itemAt('3.obj.c.0').insert 'x', 1
        v[0].expandLeaves()
        data.itemAt('3.empty.0').remove()
        data.itemAt('3.obj.b').remove()
        v[1].expandLeaves()
        v[1].expandLeaves()
        v[1].expandLeaves()
        v[1].expandLeaves()
        dump filePath

if true
    for file in ["test.json"]
        filePath = "data/#{file}"
        log "loading #{filePath} ..."
        profile "load"
        data.load filePath
        profile ''
        console.log data.root
        
        v.push new Proxy data.itemAt '5'
        v.push new Proxy data.itemAt '5'
        dump filePath
        v[0].expandLeaves()
        v[0].expandLeaves()
        v[0].collapse v[0].itemAt '3'
        v[0].collapse v[0].itemAt '5'
        dump 'collapse 5'
        
        v[0].root.expand(true)
        v[0].root.collapse()
        v[0].root.collapse(true)
        v[1].root.collapse(true)
        v[1].root.expand(true)
        v[0].itemAt('5.0').setValue 'bla'
        dump 'remove'

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

        profile 'expand recursive'
        v[0].root.expand true

        profile 'collapse recursive'
        v[0].root.collapse true
        v[0].root.expand()

        profile ''        

if true
    for file in ["cards.json"]
        filePath = "data/#{file}"
        log "loading #{filePath} ..."
        profile "load"
        data.load filePath

        profile "find"
        found = data.findKeyValue 'rarity', 'Mythic Rare'
        
        profile "find"
        found = data.findKey 'rarity'
        log "#{found.length} items"

        profile "find"
        found = data.findKeyValue 'rarity', 'Rare'
        log "#{found.length} items"
        
        profile "find"
        found = data.findValue 'Forest'
        log "#{found.length} items"

        profile 'expand recursive'
        v[0].root.expand true
        
        profile 'collapse recursive'
        v[0].root.collapse true
        v[0].root.expand()

        profile ""
        
