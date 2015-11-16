###
000   000  000  00000000  000   000
000   000  000  000       000 0 000
 000 000   000  0000000   000000000
   000     000  000       000   000
    0      000  00000000  00     00
###

log   = require './log'
Model = require './model'
Proxy = require './proxy'
Item  = require './item'

class View extends Proxy
        
    constructor: (base, @tree) -> 
        super base, 'view', @tree
        
    onWillReload:() => 
        log.debug model:@, 'willReload'
        @root = null
        
    onDidReload: () => 
        if @base?
            @root = @createItem -1, @base.root, @
        log.debug model:@, 'didReload'
        
module.exports = View
