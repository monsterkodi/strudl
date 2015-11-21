###
000   000  000  00000000  000   000
000   000  000  000       000 0 000
 000 000   000  0000000   000000000
   000     000  000       000   000
    0      000  00000000  00     00
###

_        = require 'lodash'
log      = require './log'
Model    = require './model'
Proxy    = require './proxy'
Item     = require './item'
profile  = require './profile'
ViewItem = require './viewitem'
keyname  = require './keyname'

class View extends Proxy
        
    constructor: (base, @tree) -> 
        super base, 'view', @tree
        @tree.addEventListener 'keydown', @onKeyDown
        @tree.addEventListener 'wheel', @onWheel
        @tree.tabIndex = -1
        @topIndex = 0
        @botIndex = 0
        @scroll   = 0
        
    setBase: (base) ->
        super base
        @base.on "didExpand",   @onDidExpand
        @base.on "didCollapse", @onDidCollapse
        @base.on "didLayout",   @onDidLayout

    lineHeight: -> @root?.children[0]?.elem.offsetHeight or 24
    viewHeight: -> @tree.clientHeight
    numViewLines: -> Math.floor(@tree.clientHeight / @lineHeight())
    numVisibleLines: -> @base.root.numVisible

    ###
     0000000   0000000  00000000    0000000   000      000    
    000       000       000   000  000   000  000      000    
    0000000   000       0000000    000   000  000      000    
         000  000       000   000  000   000  000      000    
    0000000    0000000  000   000   0000000   0000000  0000000
    ###
        
    scrollLines: (lines) -> @scrollBy lines * @lineHeight()

    onWheel: (event) => @scrollBy event.deltaY * 2
    
    scrollBy: (delta) ->
        @scroll += delta
        @scroll = Math.max(@scroll, 0)
        @scroll = Math.min(@scroll, (@numVisibleLines() - @numViewLines()) * @lineHeight())
        if parseInt(@scroll / @lineHeight()) != @topIndex
            @update()

    ###
    000   000  00000000   0000000     0000000   000000000  00000000
    000   000  000   000  000   000  000   000     000     000     
    000   000  00000000   000   000  000000000     000     0000000 
    000   000  000        000   000  000   000     000     000     
     0000000   000        0000000    000   000     000     00000000
    ###
        
    update: ->
        doProfile = false
        profile "update #{@numVisibleLines()}" if doProfile

        selIndex = @selectedItem()?.value.visibleIndex

        numlines = @numViewLines()
        @topIndex = parseInt(@scroll / @lineHeight())
        @botIndex = Math.min(@topIndex + numlines, @numVisibleLines()-1)
                    
        @root.children = []
        @root.keyIndex = {}
        @tree.innerHTML = "" # proper destruction needed?
                                        
        for i in [@topIndex..@botIndex]
            baseItem = @base.visibleItems[i]
            @root.keyIndex[baseItem.key] = @numVisibleLines()
            item = @createItem baseItem.key, baseItem, @root
            @root.children.push item
            item.createElement()     
            if baseItem.visibleIndex == selIndex
                item.select()
                    
        if not @selectedItem()?
            if selIndex > @botIndex
                _.last(@root.children).select()
            else
                _.first(@root.children).select()
        profile "" if doProfile
                          
    ###
    00000000   00000000  000       0000000    0000000   0000000  
    000   000  000       000      000   000  000   000  000   000
    0000000    0000000   000      000   000  000000000  000   000
    000   000  000       000      000   000  000   000  000   000
    000   000  00000000  0000000   0000000   000   000  0000000  
    ###
        
    onWillReload: => @root = null
    onDidReload: =>
        if @base?
            @root = @createItem -1, @base.root, @
            @root.elem = @tree
            
    ###
    000  000000000  00000000  00     00
    000     000     000       000   000
    000     000     0000000   000000000
    000     000     000       000 0 000
    000     000     00000000  000   000
    ###
        
    newItem: (key, value, parent) -> new ViewItem key, value, parent        
                    
    ###
    00000000  000   000  00000000    0000000   000   000  0000000  
    000        000 000   000   000  000   000  0000  000  000   000
    0000000     00000    00000000   000000000  000 0 000  000   000
    000        000 000   000        000   000  000  0000  000   000
    00000000  000   000  000        000   000  000   000  0000000  
    ###

    onDidExpand:   (baseItem) => 
    onDidCollapse: (baseItem) => 
    onDidLayout:   (baseItem) => @update()
        
    ###
    000   000  00000000  000   000  0000000     0000000   000   000  000   000
    000  000   000        000 000   000   000  000   000  000 0 000  0000  000
    0000000    0000000     00000    000   000  000   000  000000000  000 0 000
    000  000   000          000     000   000  000   000  000   000  000  0000
    000   000  00000000     000     0000000     0000000   00     00  000   000
    ###
    
    selectedItem: () -> @root.children[parseInt(document.activeElement.id)]
    
    selectUp: (event) -> 
        
        if not @selectedItem().prevItem()? or event.shiftKey
            @scrollLines -1
        @selectedItem().prevItem()?.select()
        
    selectDown: (event) -> 
        
        if not @selectedItem().nextItem()? or event.shiftKey
            @scrollLines 1
        @selectedItem().nextItem()?.select()
    
    onKeyDown: (event) =>
        keycode = keyname.keycode event
        switch keycode
            when 'left', 'right'
                @selectedItem()?["select#{_.capitalize(keycode)}"] event
            when 'up'  then @selectUp event
            when 'down'then @selectDown event
            when 'page up', 'page down'
                @scrollLines((keycode == 'page up' and -1 or 1) * @numViewLines())
                _.first(@root.children).select()
        
module.exports = View
