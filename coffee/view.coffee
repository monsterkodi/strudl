###
000   000  000  00000000  000   000
000   000  000  000       000 0 000
 000 000   000  0000000   000000000
   000     000  000       000   000
    0      000  00000000  00     00
###

_        = require 'lodash'
log      = require './tools/log'
Model    = require './model'
Proxy    = require './proxy'
Item     = require './item'
profile  = require './tools/profile'
ViewItem = require './viewitem'
keyname  = require './tools/keyname'

class View extends Proxy
        
    constructor: (base, @tree) -> 
        super base, 'view', @tree
        @tree.addEventListener 'keydown', @onKeyDown
        @tree.addEventListener 'wheel', @onWheel
        @tree.tabIndex = -1
        @topIndex = 0
        @botIndex = 0
        @scroll   = 0
        @scrollLeft = @tree.parentElement.getElementsByClassName('scroll left')[0]
        # log 'View scrollLeft', @scrollLeft
        
        tmp = document.createElement 'div'
        tmp.className = 'tree-item'
        @tree.appendChild tmp
        @lineHeight = tmp.offsetHeight
        tmp.remove()
        log 'View', @lineHeight
        
    setBase: (base) ->
        super base
        @base.on "didExpand",   @onDidExpand
        @base.on "didCollapse", @onDidCollapse
        @base.on "didLayout",   @onDidLayout

    viewHeight: -> @tree.clientHeight
    numViewLines: -> Math.floor @viewHeight() / @lineHeight
    numVisibleLines: -> @base.root.numVisible

    ###
     0000000   0000000  00000000    0000000   000      000    
    000       000       000   000  000   000  000      000    
    0000000   000       0000000    000   000  000      000    
         000  000       000   000  000   000  000      000    
    0000000    0000000  000   000   0000000   0000000  0000000
    ###
        
    scrollLines: (lineDelta) -> @scrollBy lineDelta * @lineHeight

    scrollFactor: (event) ->
        f  = 1 
        f *= 1 + 9 * event.metaKey
        f *= 1 + 99 * event.altKey        
        f *= 1 + 999 * event.ctrlKey

    onWheel: (event) => 
        @scrollBy event.deltaY * @scrollFactor event
    
    scrollBy: (delta) -> 

        @treeHeight = @numVisibleLines() * @lineHeight
        @linesHeight = @numViewLines() * @lineHeight
        @scrollMax = @treeHeight - @linesHeight
        
        @scroll += delta
        @scroll = Math.max @scroll, 0
        @scroll = Math.min @scroll, @scrollMax
        
        @update() if @topIndex != parseInt @scroll / @lineHeight

    updateScroll: ->
        scrollTop = parseInt (@scroll / @treeHeight) * @viewHeight()
        scrollTop = Math.max 0, scrollTop
        scrollHeight = parseInt (@linesHeight / @treeHeight) * @viewHeight()
        scrollHeight = Math.max scrollHeight, parseInt @lineHeight/4
        
        @scrollLeft.classList.toggle 'flashy', (scrollHeight < @lineHeight)
        
        @scrollLeft.style.top    = "#{scrollTop}.px"
        @scrollLeft.style.height = "#{scrollHeight}.px"
                          

    ###
    000   000  00000000   0000000     0000000   000000000  00000000
    000   000  000   000  000   000  000   000     000     000     
    000   000  00000000   000   000  000000000     000     0000000 
    000   000  000        000   000  000   000     000     000     
     0000000   000        0000000    000   000     000     00000000
    ###
        
    update: ->
        doProfile = false
        numLines = @numVisibleLines()
        viewLines = @numViewLines()

        profile "update #{numLines}" if doProfile

        selIndex = @selectedItem()?.value.visibleIndex

        @lineHeight
        @treeHeight = numLines * @lineHeight
        @linesHeight = viewLines * @lineHeight
        
        @topIndex = parseInt(@scroll / @lineHeight)
        @botIndex = Math.min(@topIndex + viewLines, numLines-1)
                                
        @root.children = []
        @root.keyIndex = {}
        @tree.innerHTML = "" # proper destruction needed?
                                        
        for i in [@topIndex..@botIndex]
            baseItem = @base.visibleItems[i]
            @root.keyIndex[baseItem.key] = numLines
            item = @createItem baseItem.key, baseItem, @root
            @root.children.push item
            item.createElement()     
            if baseItem.visibleIndex == selIndex and not @partiallyVisible item
                item.select()
                    
        if not @selectedItem()?
            if selIndex >= @botIndex
                last = _.last(@root.children)
                if @partiallyVisible last
                    last = last.prevItem()
                last.select()
            else
                _.first(@root.children).select()
                
        @updateScroll()
                
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
    partiallyVisible: (item) -> (item.elem.offsetTop + item.elem.offsetHeight) > @viewHeight()
                    
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
    
    selectLines: (lineDelta) ->
        if @selectedItem()?
            idx = @selectedItem().value.visibleIndex
        @scrollLines lineDelta
        
    selectUp: (event) -> 

        if 1 < f = @scrollFactor event
            @selectLines -f
            return
        
        if not @selectedItem().prevItem()? or event.shiftKey
            @scrollLines -1
        @selectedItem().prevItem()?.select()
        
    selectDown: (event) -> 
        
        if 1 < f = @scrollFactor event
            @selectLines f
            return
        
        if not @selectedItem().nextItem()? or event.shiftKey or @partiallyVisible @selectedItem().nextItem()
            @scrollLines 1
        @selectedItem().nextItem()?.select()
    
    onKeyDown: (event) =>
        keycode = keyname.keycode event
        switch keycode
            when 'left', 'right'
                if event.metaKey and event.altKey
                    if keycode == 'left'
                        @base.collapseTop true
                    else
                        @base.expandTop true
                else
                    @selectedItem()?["select#{_.capitalize(keycode)}"] event
            when 'up'  then @selectUp event
            when 'down'then @selectDown event
            when 'page up', 'page down'
                n = event.shiftKey and @numVisibleLines() or @numViewLines()
                @scrollLines(keycode == 'page up' and -n or n)
                first = _.first @root.children
                last  = _.last @root.children
                if last.value.visibleIndex == @numVisibleLines()-1
                    last.select()
                else
                    first.select()
        
module.exports = View
