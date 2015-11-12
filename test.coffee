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

data = new Data()
v = []
v.push new Proxy data
# v.push new Proxy data

dump = (msg) ->
    log '-------------------------------- ' + msg
    # log data.root
    for vw in v
        log ''
        log vw.root

# for file in ["darwin.cson", "test.json", "config.cson", "fish.cson", "swift.cson"]
# for file in ["test.cson"]
# for file in ["data.json"]
for file in ["cards.json"]
    log "loading ..."
    filePath = "data/#{file}"
    profile "load"
    data.load filePath
    # dump filePath

    # node = v[0].itemAt 'Entity'
    # v[0].expand node
    # v[0].expandItems v[0].leafItems(node)
    # v[0].expandItems v[0].leafItems(node)
    # v[0].expandItems v[0].leafItems(node)
    # log v[1].root
    # v[1].expandLeaves()
    # v[1].expandLeaves()
    # log v[1].root
    # log data.find 'objectType', 5667815
    # data.find 'uid'

    profile "find"
    found = data.find 'rarity', 'Mythic Rare'
    
    profile "find"
    found = data.find 'rarity'

    profile "find"
    found = data.find 'rarity', 'Mythic Rare'
    
    profile "find"
    found = data.find 'rarity'
    
    # profile "log"
    # for path in found
    #     log path.join('.'), data.dataAt(path)['rarity']
    profile ""

    # p = ['view1', 'view2']
    # for e in [1..4]
    #     for i in [0...2]
    #         v[i].expand v[i].itemAt p[i]
    #         p[i] += '.' + e
    #     dump 'expand ' + e
        
    # for e in [1..2]
    #     log e
    #     profile.start "expand"
    #     v[0].expandLeaves()
    #     # v[1].expandLeaves()
    #     profile.end()
    # v[0].expandLeaves()
    # dump 'expanded'

    # v[0].collapseTop()
    # v[1].collapseTop()
    # dump 'collapsed'
    # 
    # v[0].collapseTop(true)
    # v[1].collapseTop(true)
    # dump 'collapsed'
