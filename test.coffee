###
000000000  00000000   0000000  000000000
   000     000       000          000   
   000     0000000   0000000      000   
   000     000            000     000   
   000     00000000  0000000      000   
###

Model     = require './model'
DataModel = require './data'
log       = require './log'

for file in ["config.cson", "darwin.cson", "fish.cson", "swift.cson", "test.json"]
    filePath = "data/#{file}"
    log ''
    log '--------------------------------', filePath
    log ''
    data = new DataModel()
    new Model data
    data.load filePath
    data.expandAll()
    data.expandAll()
    data.expandAll()
    data.expandAll()
    data.expandAll()
    data.expandAll()
    data.expandAll()
    log data.root
