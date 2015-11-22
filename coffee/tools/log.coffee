###
000       0000000    0000000 
000      000   000  000      
000      000   000  000  0000
000      000   000  000   000
0000000   0000000    0000000 
###

str = require './str'
fs  = require 'fs'
            
module.exports = -> 
    msg = (str(a) for a in arguments).join(' ')
    console.log msg
    stream = fs.createWriteStream('strudl.log', flags: 'a', encoding: 'utf8')
    stream.write msg + "\n"
    stream.end()
