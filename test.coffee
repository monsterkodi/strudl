###
000000000  00000000   0000000  000000000
   000     000       000          000   
   000     0000000   0000000      000   
   000     000            000     000   
   000     00000000  0000000      000   
###

Proxy = require './proxy'
Data  = require './data'
log   = require './log'

data = new Data()
v = []
v.push new Proxy data
v.push new Proxy data

dump = (msg) ->
    log '-------------------------------- ' + msg
    # log data.root
    for vw in v
        log ''
        log vw.root

for file in ["darwin.cson", "test.json", "config.cson", "fish.cson", "swift.cson"]
# for file in ["test.cson"]
    filePath = "data/#{file}"
    data.load filePath
    dump(filePath)

    # p = ['view1', 'view2']
    # for e in [1..4]
    #     for i in [0...2]
    #         v[i].expand v[i].itemAt p[i]
    #         p[i] += '.' + e
    #     dump 'expand ' + e
        
    for e in [1..6]
        v[0].expandLeaves()
        v[1].expandLeaves()
        dump 'expanded'

    v[0].collapseTop()
    v[1].collapseTop()
    dump 'collapsed'

    v[0].collapseTop(true)
    v[1].collapseTop(true)
    dump 'collapsed'
