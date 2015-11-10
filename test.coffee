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
log json.json

json.root.value[0].setValue 'fark'
json.get('5.1').setValue 'fork'

log json.root
log json.json
