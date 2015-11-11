###
000000000  00000000   0000000  000000000
   000     000       000          000   
   000     0000000   0000000      000   
   000     000            000     000   
   000     00000000  0000000      000   
###

Model     = require './model'
JSONModel = require './json'
log       = require './log'

json = new JSONModel()
expd = new Model()
expd.setBase json

json.load "test.json"
# json.load "data.json"
# log json.root
# json.expandAll()
# # log json.root
# json.collapseAll()
# # log json.root
json.expandAll()
log json.root

json.expandAll()
log json.root

json.expandAll()
log json.root

json.expandAll()
log json.root

json.expandAll()
log json.root
