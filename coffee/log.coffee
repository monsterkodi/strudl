###
000       0000000    0000000 
000      000   000  000      
000      000   000  000  0000
000      000   000  000   000
0000000   0000000    0000000 
###

str    = require './str'
fs     = require 'fs'
    
stream = fs.createWriteStream('strudl.log', flags: 'a', encoding: 'utf8')
stream.closeOnExit = true
        
module.exports = -> 
    msg = (str(a) for a in arguments).join(' ')
    console.log msg
    stream.write msg + "\n"
    
    # console.log.apply console.log, Array.prototype.slice.call(arguments, 0)
