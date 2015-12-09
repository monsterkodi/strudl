###
0000000    00000000  00000000
000   000  000       000     
000   000  0000000   000000  
000   000  000       000     
0000000    00000000  000     
###

_ = require 'lodash'

def = (c,d) ->
    if c?
        _.defaults(_.clone(c), d)
    else if d?
        _.clone(d)
    else
        {}

module.exports = def
