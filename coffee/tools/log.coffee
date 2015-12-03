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
    
    try
        if process.env['USER'] == 'kodi'
            msg = (str(a) for a in arguments).join(' ') + "\n"
            fs.appendFileSync('/Users/kodi/Projects/strudl/strudl.log', msg, encoding: 'utf8')
            # stream = fs.createWriteStream('/Users/kodi/Projects/strudl/strudl.log', flags: 'a+', encoding: 'utf8')
            # stream.write msg + "\n"
            # stream.end()
            console.log msg
    catch
        console.log msg
