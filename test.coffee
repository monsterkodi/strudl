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

# for file in ["config.cson", "darwin.cson", "fish.cson", "swift.cson", "test.json"]
for file in ["test.cson"]
    filePath = "data/#{file}"
    data = new Data()
    v = []
    v.push new Proxy data
    v.push new Proxy data
    data.load filePath

    dump = (msg) ->
        log '-------------------------------- ' + msg
        # log data.root
        for i in [0...2]
            log ''
            log v[i].root

    dump(filePath)

    p = ['view1', 'view2']
    for e in [1..4]
        for i in [0...2]
            v[i].expand v[i].itemAt p[i]
            p[i] += '.' + e
        dump 'expand ' + e
        
    v[0].collapseTop()
    v[1].itemAt('view2.1.2').collapse()
    dump 'collapsed'

    for e in [1..6]
        v[0].expandLeaves()
        v[1].expandLeaves()
        dump 'expanded'

    v[0].collapseTop()
    v[1].collapseTop()
    dump 'expanded'

    v[0].collapseTop(true)
    v[1].collapseTop(true)
    dump 'expanded'
