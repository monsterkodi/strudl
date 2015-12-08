###
 0000000   0000000     0000000   000   000  000000000
000   000  000   000  000   000  000   000     000   
000000000  0000000    000   000  000   000     000   
000   000  000   000  000   000  000   000     000   
000   000  0000000     0000000    0000000      000   
###

remote = require 'remote'

openURL = (url) -> require("opener")(url)

openFile = -> remote.getCurrentWindow().emit 'openFileDialog'
