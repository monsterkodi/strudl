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
Path     = require './path'
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
        @selIndex = 0
        @scroll   = 0
        @scrollLeft = @tree.parentElement.getElementsByClassName('scroll left')[0]
        
        @keyPath = new Path $('path')
        
        tmp = document.createElement 'div'
        tmp.className = 'tree-item'
        @tree.appendChild tmp
        @lineHeight = tmp.offsetHeight
        tmp.remove()
        
    setBase: (base) ->
        super base
        @base.on "didLayout",   @onDidLayout

    viewHeight: -> @tree.parentElement.parentElement.offsetHeight - $('path').offsetHeight
    numViewLines: -> Math.ceil(@viewHeight() / @lineHeight)
    numFullLines: -> Math.floor(@viewHeight() / @lineHeight)
    numVisibleLines: -> @base.root.numVisible

    ###
     0000000   0000000  00000000    0000000   000      000    
    000       000       000   000  000   000  000      000    
    0000000   000       0000000    000   000  000      000    
         000  000       000   000  000   000  000      000    
    0000000    0000000  000   000   0000000   0000000  0000000
    ###
        
    updateScroll: ->
        
        scrollTop = parseInt (@scroll / @treeHeight) * @viewHeight()
        scrollTop = Math.max 0, scrollTop
        scrollHeight = parseInt (@linesHeight / @treeHeight) * @viewHeight()
        scrollHeight = Math.max scrollHeight, parseInt @lineHeight/4
        
        @scrollLeft.classList.toggle 'flashy', (scrollHeight < @lineHeight)
        
        @scrollLeft.style.top    = "#{scrollTop}.px"
        @scrollLeft.style.height = "#{scrollHeight}.px"
        
    scrollLines: (lineDelta) -> @scrollBy lineDelta * @lineHeight

    scrollFactor: (event) ->
        f  = 1 
        f *= 1 + 9 * event.metaKey
        f *= 1 + 99 * event.altKey        
        f *= 1 + 999 * event.ctrlKey

    onWheel: (event) => @scrollBy event.deltaY * @scrollFactor event
    
    scrollBy: (delta) -> 

        numLines = @numVisibleLines()
        viewLines = @numViewLines()
        @treeHeight = numLines * @lineHeight
        @linesHeight = viewLines * @lineHeight
        @scrollMax = @treeHeight - @linesHeight
        
        @scroll += delta
        @scroll = Math.min @scroll, @scrollMax
        @scroll = Math.max @scroll, 0
        
        top = parseInt @scroll / @lineHeight
        bot = Math.min(parseInt((@scroll + @linesHeight) / @lineHeight), numLines-1)

        if @topIndex != top or @botIndex != bot
            if @selIndex < top
                @selectIndex top
            else if @selIndex > bot
                @scroll = Math.max(0, bot - viewLines) * @lineHeight
                @selectIndex bot
            else
                @update() 
                @selectedItem().focus()
            
    ###
     0000000  00000000  000      00000000   0000000  000000000
    000       000       000      000       000          000   
    0000000   0000000   000      0000000   000          000   
         000  000       000      000       000          000   
    0000000   00000000  0000000  00000000   0000000     000   
    ###
    
    selectedItem: () -> @closestItemForVisibleIndex @selIndex
    
    selectIndex: (index) ->
        @selIndex = index
        @selIndex = Math.max(0, Math.min @selIndex, @numVisibleLines()-1)
        log 'selectIndex', @selIndex
        @keyPath.set @selectedItem().dataItem().keyPath()
        @update()
        @selectedItem().focus()
    
    selectDelta: (lineDelta) -> @selectIndex @selIndex + lineDelta
        
    selectUp: (event) -> @selectDelta -@scrollFactor event
        
    selectDown: (event) -> @selectDelta @scrollFactor event

    ###
    000   000  00000000   0000000     0000000   000000000  00000000
    000   000  000   000  000   000  000   000     000     000     
    000   000  00000000   000   000  000000000     000     0000000 
    000   000  000        000   000  000   000     000     000     
     0000000   000        0000000    000   000     000     00000000
    ###
        
    update: ->
        
        doProfile = false
        numLines  = @numVisibleLines()
        viewLines = @numViewLines()

        profile "update #{numLines}" if doProfile

        @treeHeight = numLines * @lineHeight
        @linesHeight = viewLines * @lineHeight

        @topIndex = parseInt @scroll / @lineHeight
        @botIndex = Math.min(parseInt((@scroll + @linesHeight) / @lineHeight), numLines-1)

        if @selIndex < @topIndex
            @topIndex = @selIndex
            @botIndex = Math.min(@topIndex + viewLines - 1, numLines-1)
            @scroll = @topIndex * @lineHeight
        else if @selIndex > @topIndex + @numFullLines() - 1 
            @botIndex = @selIndex
            @topIndex = Math.max(0, @botIndex - @numFullLines() + 1)
            @scroll = @topIndex * @lineHeight
        
        log 'update after', @selIndex, @botIndex - @topIndex
        
        @root.children = []
        @root.keyIndex = {}
        @tree.innerHTML = "" # proper destruction needed?
                
        # log 'view.update', viewLines, numLines, @viewHeight()
                                        
        for i in [@topIndex..@botIndex]
            baseItem = @base.visibleItems[i]
            @root.keyIndex[baseItem.key] = numLines
            item = @createItem baseItem.key, baseItem, @root
            @root.children.push item
            item.createElement()     
                
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
    
    closestItemForVisibleIndex: (index) ->
        if index <= _.first(@root.children).value.visibleIndex
            return _.first(@root.children)
        if index >= _.last(@root.children).value.visibleIndex
            return _.last(@root.children)
        for item in @root.children
            if item.value.visibleIndex == index
                return item
                    
    ###
    00000000  000   000  00000000    0000000   000   000  0000000  
    000        000 000   000   000  000   000  0000  000  000   000
    0000000     00000    00000000   000000000  000 0 000  000   000
    000        000 000   000        000   000  000  0000  000   000
    00000000  000   000  000        000   000  000   000  0000000  
    ###

    onDidLayout: (baseItem) => @update()
        
    ###
    000   000  00000000  000   000  0000000     0000000   000   000  000   000
    000  000   000        000 000   000   000  000   000  000 0 000  0000  000
    0000000    0000000     00000    000   000  000   000  000000000  000 0 000
    000  000   000          000     000   000  000   000  000   000  000  0000
    000   000  00000000     000     0000000     0000000   00     00  000   000
    ###
    
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
            when 'home' then @selectDelta -@numVisibleLines()
            when 'end'  then @selectDelta  @numVisibleLines()
            when 'up'   then @selectUp event
            when 'down' then @selectDown event
            when 'page up', 'page down'
                n = event.shiftKey and @numVisibleLines() or @numViewLines()
                @scrollLines(keycode == 'page up' and -n or n)
                first = _.first @root.children
                last  = _.last @root.children
                if last.value.visibleIndex == @numVisibleLines()-1
                    last.select()
                else
                    first.select()
            else
                log keycode
        
module.exports = View
