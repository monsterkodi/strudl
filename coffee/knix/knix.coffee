###
000   000  000   000  000  000   000
000  000   0000  000  000   000 000 
0000000    000 0 000  000    00000  
000  000   000  0000  000   000 000 
000   000  000   000  000  000   000
###

_           = require 'lodash'
Widget      = require './widget'
Stage       = require './stage'
Menu        = require './menu'
tools       = require './tools'
str         = require './str'
def         = require './def'
log         = require '../tools/log'

class knix

    @init: (config={}) =>
                
        @initMenu()
        Stage.init()
        @
    
    ###
    00     00  00000000  000   000  000   000   0000000
    000   000  000       0000  000  000   000  000     
    000000000  0000000   000 0 000  000   000  0000000 
    000 0 000  000       000  0000  000   000       000
    000   000  00000000  000   000   0000000   0000000 
    ###
        
    @initMenu: =>
        
        mainMenu = new Menu
            id:     'menu'
            parent: 'menu-bar'
            style:  
                top: '0px'
            
        toolMenu = new Menu
            id:     'tool'
            parent: 'menu-bar'
            style:  
                top:   '0px'
                right: '0px'
        
    ###
     0000000  00000000   00000000   0000000   000000000  00000000
    000       000   000  000       000   000     000     000     
    000       0000000    0000000   000000000     000     0000000 
    000       000   000  000       000   000     000     000     
     0000000  000   000  00000000  000   000     000     00000000
    ###

    @create: (cfg, defs) =>

        cfg = def cfg, defs
        # dbg cfg
        if cfg.type? 
            try
                cls = require './'+cfg.type
                # dbg cls
                return new cls cfg
            catch err
                # log cfg.type, err
                0

        # log 'plain'
        new Widget cfg, { type: 'widget' }

    # ________________________________________________________________________________ get

    # shortcut to call @create with default type window and stage as parent

    @get: (cfg, defs) =>
        cfg = def cfg, defs
        w = @create def cfg,
            type:   'window'
            parent: 'stage'
        Stage.positionWindow(w) if w.isWindow?()
        w
                            
    ###
    000000000   0000000    0000000   000      000000000  000  00000000    0000000
       000     000   000  000   000  000         000     000  000   000  000     
       000     000   000  000   000  000         000     000  00000000   0000000 
       000     000   000  000   000  000         000     000  000             000
       000      0000000    0000000   0000000     000     000  000        0000000 
    ###

    @addPopup: (p) =>
        @popups = [] if not @popups?
        @popups.push p
        if not @popupHandler?
            @popupHandler = document.addEventListener 'mousedown', @closePopups
            
    @delPopup: (p) =>
        @popups = @popups.without p

    @closePopups: (event) =>
        e = event?.target
        if @popups?
            for p in @popups
                p.close() for p in @popups when e not in p.elem.descendants()
        if @popupHandler?
            @popupHandler.stop()
            delete @popupHandler

module.exports = knix
