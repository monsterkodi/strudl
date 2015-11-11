###
000000000  00000000   0000000  000000000
   000     000       000          000   
   000     0000000   0000000      000   
   000     000            000     000   
   000     00000000  0000000      000   
###

DataModel = require './data'
log       = require './log'

# json = new JSONModel()
# new Model().setBase json
# json.load "test.json"
# 
# json.expandAll()
# log json.root
# 
# json.expandAll()
# log json.root
# 
# json.expandAll()
# log json.root
# 
# json.expandAll()
# log json.root
# 
# json.expandAll()
# log json.root

for file in ["config.cson", "darwin.cson", "fish.cson", "swift.cson", "test.json"]
    filePath = "data/#{file}"
    log ''
    log '--------------------------------', filePath
    log ''
    cson = new DataModel()
    new Model().setBase cson
    cson.load filePath
    # log cson.root
    cson.expandAll()
    # log cson.root
    cson.expandAll()
    # log cson.root
    cson.expandAll()
    cson.expandAll()
    cson.expandAll()
    cson.expandAll()
    cson.expandAll()
    log cson.root
