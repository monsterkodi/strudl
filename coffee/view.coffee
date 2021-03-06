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
Find     = require './find'
Drag     = require './drag'
Sizer    = require './sizer'
profile  = require './tools/profile'
ViewItem = require './viewitem'
keyname  = require './tools/keyname'

class View extends Proxy
        
    constructor: (base, @tree) -> 
        super base, 'view', @tree
        @tree.addEventListener 'keydown', @onKeyDown
        @tree.addEventListener 'wheel',   @onWheel

        @topIndex = 0
        @botIndex = 0
        @selIndex = -1
        @scroll   = 0
        
        tp = @tree.parentElement
        @scrollLeft = @getElem 'scroll left', tp
        @leftDrag = new Drag @getElem 'scrollbar left', tp
        @leftDrag.on 'drag', @onScrollDrag 

        @scrollRight = @getElem 'scroll right', tp
        @rightDrag = new Drag @getElem 'scrollbar right', tp
        @rightDrag.on 'drag', @onScrollDrag 
                
        @keyPath = new Path document.getElementById 'path'
        @keyPath.on 'keypath', @onKeyPath
        
        @find = new Find @, document.getElementById 'find'
        @find.on 'blur', @refocus
        @find.on 'hidden', @refocus
        @find.on 'applied', @onFindApplied
        @find.elem.style.display = 'none'
        
        tmp = document.createElement 'div'
        tmp.className = 'tree-item'
        @tree.appendChild tmp
        @lineHeight = tmp.offsetHeight
        tmp.remove()
                                
    setBase: (base) ->
        super base
        @base.on "didLayout", @onDidLayout

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
            
    viewHeight: -> document.getElementById('stage').offsetHeight - document.getElementById('path').offsetHeight  - document.getElementById('find').offsetHeight
    numViewLines: -> Math.ceil(@viewHeight() / @lineHeight)
    numFullLines: -> Math.floor(@viewHeight() / @lineHeight)
    numVisibleLines: -> @base.root?.numVisible or 0

    ###
    000   000  00000000   0000000     0000000   000000000  00000000
    000   000  000   000  000   000  000   000     000     000     
    000   000  00000000   000   000  000000000     000     0000000 
    000   000  000        000   000  000   000     000     000     
     0000000   000        0000000    000   000     000     00000000
    ###

    updateItem: (item, key, value, parent) -> 
        item.updateElement key, value, parent
        item.id = @nextID()
        item.unfetched = true if item.isExpandable()
        @itemMap[value.id] = item
        item
        
    update: ->
        
        doProfile = false
        numLines  = @numVisibleLines()
        viewLines = @numViewLines()
        
        profile "update #{numLines}" if doProfile
        
        setFocus = @hasFocus()
        # dbg setFocus, document.activeElement?.className
        
        @treeHeight = numLines * @lineHeight
        @linesHeight = viewLines * @lineHeight

        @topIndex = parseInt @scroll / @lineHeight    
        @botIndex = Math.min(@topIndex + viewLines - 1, numLines-1)
        
        if @selIndex < @topIndex
            @topIndex = @selIndex
            @botIndex = Math.min(@topIndex + viewLines - 1, numLines-1)
            if @botIndex - @topIndex < Math.min(viewLines, numLines) - 1
                @topIndex = @botIndex - Math.min(viewLines, numLines) + 1
            @scroll = @topIndex * @lineHeight
        else if @selIndex >= @topIndex + @numFullLines()
            @topIndex = @selIndex - @numFullLines() + 1
            @topIndex = Math.max(0, @topIndex)
            @botIndex = Math.min(@topIndex + viewLines - 1, numLines-1)
            @scroll = @topIndex * @lineHeight
        
        if not @items?
            @items = []
        
        while (@items.length-1) > (@botIndex-@topIndex)
            _.last(@items).removeElement()
            @items.pop()
            
        if numLines
            @root.children = []
            @root.keyIndex = {}
                    
            for i in [@topIndex..@botIndex]
                baseItem = @base.visibleItems[i]
                @root.keyIndex[baseItem.key] = numLines
                
                relIndex = i-@topIndex
                if relIndex < @items.length
                    item = @items[relIndex]
                    @updateItem item, baseItem.key, baseItem, @root
                else
                    item = @createItem baseItem.key, baseItem, @root
                    item.createElement() 
                    @items.push item
                @root.children.push item

            @updateSize()
            @updateScroll()
                    
            selItem = @closestItemForVisibleIndex @selIndex
            if setFocus 
                selItem.setFocus()
            else
                selItem.ownClass "selected", selItem.lin
                
            if selItem.value.visibleIndex != @selIndex
                @selIndex = selItem.value.visibleIndex
                
            keypath = @base.visibleItems[@selIndex].dataItem().keyPath()
            if @keyPath.key != keypath
                @keyPath.set keypath
                    
            @tree.children[1].scrollLeft = selItem.elm.scrollWidth - @tree.children[1].clientWidth
        else
            @keyPath.set []
            @scroll = 0
            @treeHeight = @lineHeight
            @updateScroll()
            
        window.getSelection().empty()        
        
        profile "" if doProfile

    ###
     0000000  000  0000000  00000000
    000       000     000   000     
    0000000   000    000    0000000 
         000  000   000     000     
    0000000   000  0000000  00000000
    ###
        
    updateSize: ->
        [ic,kc,vc,nc] = [@col('idx'), @col('key'), @col('val'), @col('num')]
        [ix,kx,vx,nx] = [ic.offsetLeft, kc.offsetLeft, vc.offsetLeft, nc.offsetLeft]
        [iw,kw,vw,nw] = [ic.offsetWidth, kc.offsetWidth, vc.offsetWidth, nc.offsetWidth]

        if vc.style.display == 'none'
            @setWidth kc, @getWidth(@tree) - nw - iw
        else if kc.style.display == 'none'
            @setWidth vc, @getWidth(@tree) - nw - iw
        else 
            as = @getWidth(@tree) - nw - iw
            ks = as * @sizer.pos
            @setWidth kc, ks
            @setWidth vc, as - ks
        
        @sizer.update()

    ###
    000       0000000   000   000   0000000   000   000  000000000
    000      000   000   000 000   000   000  000   000     000   
    000      000000000    00000    000   000  000   000     000   
    000      000   000     000     000   000  000   000     000   
    0000000  000   000     000      0000000    0000000      000   
    ###
    
    col: (name) -> @getElem name

    onResizeColumn: (x, dx) ->

        [kc,vc] = [@col('key'), @col('val')]
        [kx,kw] = [kc.offsetLeft, @getWidth kc]
        [vx,vw] = [vc.offsetLeft, @getWidth vc]
        [kr,vr] = [kx+kw, vx+vw]
        [sx,sr] = [x-kx+dx, vw-x-dx+vx]

        if sx <= 100 or sr <= 100
            return false
        else
            @setWidth kc, sx
            @setWidth vc, (kw+vw) - sx
            
        @update()
        true

    onDidLayout: (baseItem) => 
        if not @sizer
            @sizer = new Sizer @

        if @selIndex < 0
            @selectIndex 0
            @update()
            @root.children[0]?.setFocus()
            return
        else if @selIndex >= @numVisibleLines()
            @selectIndex @numVisibleLines() - 1 
        @update()

    toggleColumn: (c) -> 
        @setColumnVisible c, @col(c).style.display == 'none'
                    
    setColumnVisible: (c, v) -> 

        @col(c).style.display = v and 'inline-block' or 'none'
        
        if @col('val').style.display == 'none' or @col('key').style.display == 'none'
            @sizer.hide()
            if @col('val').style.display == 'none' and @col('key').style.display == 'none'
                @col(c == 'key' and 'val' or 'key').style.display = 'inline-block'
        else 
            @sizer.show()
        @update()
            
    ###
     0000000   0000000  00000000    0000000   000      000    
    000       000       000   000  000   000  000      000    
    0000000   000       0000000    000   000  000      000    
         000  000       000   000  000   000  000      000    
    0000000    0000000  000   000   0000000   0000000  0000000
    ###
        
    updateScroll: ->
        vh           = Math.min @linesHeight, @viewHeight()
        scrollTop    = parseInt (@scroll / @treeHeight) * vh
        scrollTop    = Math.max 0, scrollTop
        scrollHeight = parseInt (@linesHeight / @treeHeight) * vh
        scrollHeight = Math.max scrollHeight, parseInt @lineHeight/4
        scrollTop    = Math.min scrollTop, @numFullLines()*@lineHeight-scrollHeight-1
        
        @scrollLeft.classList.toggle 'flashy', (scrollHeight < @lineHeight)
        @scrollLeft.style.top    = "#{scrollTop}.px"
        @scrollLeft.style.height = "#{scrollHeight}.px"

        @scrollRight.classList.toggle 'flashy', (scrollHeight < @lineHeight)
        @scrollRight.style.top    = "#{scrollTop}.px"
        @scrollRight.style.height = "#{scrollHeight}.px"
                
    scrollLines: (lineDelta) -> @scrollBy lineDelta * @lineHeight

    scrollFactor: (event) ->
        f  = 1 
        f *= 1 + 9 * event.metaKey
        f *= 1 + 99 * event.altKey        
        f *= 1 + 999 * event.ctrlKey

    onWheel: (event) => @scrollBy event.deltaY * @scrollFactor event
    
    onScrollDrag: (drag) =>
        delta = -(drag.dy / @linesHeight) * @treeHeight
        @scrollBy delta

    onDrag: (drag) => @scrollBy drag.dy
    
    scrollBy: (delta) -> 

        numLines = @numVisibleLines()
        viewLines = @numViewLines()
        @treeHeight = numLines * @lineHeight
        @linesHeight = viewLines * @lineHeight
        @scrollMax = @treeHeight - @linesHeight + @lineHeight
        
        @scroll += delta
        @scroll = Math.min @scroll, @scrollMax
        @scroll = Math.max @scroll, 0
        
        top = parseInt @scroll / @lineHeight
        bot = Math.min(@topIndex + viewLines - 1, numLines - 1)

        if @topIndex != top or @botIndex != bot
            if @selIndex < top
                @selectIndex top
            else if @selIndex >= top + @numFullLines()
                @selectIndex top + @numFullLines() - 1
            @update() 
                        
    ###
     0000000  00000000  000      00000000   0000000  000000000
    000       000       000      000       000          000   
    0000000   0000000   000      0000000   000          000   
         000  000       000      000       000          000   
    0000000   00000000  0000000  00000000   0000000     000   
    ###
    
    hasFocus: -> document.activeElement.classList.contains 'tree-line-focus'
    
    selectedItem: -> @closestItemForVisibleIndex @selIndex
    
    selectIndex: (index) ->
        @selIndex = index
        @selIndex = Math.max(0, Math.min @selIndex, @numVisibleLines()-1)
        @keyPath.set @base.visibleItems[@selIndex]?.dataItem().keyPath()
        if @selIndex < @topIndex or @selIndex >= @topIndex + @numFullLines()
            @update()
        else if @hasFocus()
            @selectedItem()?.setFocus()
        else 
            @selectedItem()?.setSelected()
    
    selectDelta: (lineDelta) -> @selectIndex @selIndex + lineDelta
        
    selectUp: (event) -> @selectDelta -@scrollFactor event
        
    selectDown: (event) -> @selectDelta @scrollFactor event

    onKeyPath: (keypath) => @selectIndex @base.itemAt(keypath).visibleIndex
        
    focusSelected: => 
        if not @hasFocus()
            @selectedItem().setFocus()       
                        
    collapseSubtree: (recursive=false) -> 
        if recursive
            @selectedItem().collapse true
        else
            @base.collapseLeaves @selectedItem().value
    expandSubtree:   (recursive=false) -> @base.expandLeaves @selectedItem().value,   recursive    
        
    ###
    000  000000000  00000000  00     00
    000     000     000       000   000
    000     000     0000000   000000000
    000     000     000       000 0 000
    000     000     00000000  000   000
    ###
                
    newItem: (key, value, parent) -> new ViewItem key, value, parent     
    partiallyVisible: (item) -> (item.key.offsetTop + item.key.offsetHeight) > @viewHeight()
    
    closestItemForVisibleIndex: (index) ->
        if @root.children.length
            if index <= _.first(@root.children).value.visibleIndex
                return _.first(@root.children)
            if index >= _.last(@root.children).value.visibleIndex
                return _.last(@root.children)
            for item in @root.children
                if item.value.visibleIndex == index
                    return item
            
    onWillRemove: (item) =>
    onDidInsert: (baseItems) => @update()
            
    ###
    00000000  000      00000000  00     00
    000       000      000       000   000
    0000000   000      0000000   000000000
    000       000      000       000 0 000
    00000000  0000000  00000000  000   000
    ###
        
    getWidth: (e) -> parseInt(window.getComputedStyle(e).width)
    setWidth: (e,w) -> e.style.width = "#{w}px"
    getElem: (clss,e=@tree) -> e.getElementsByClassName(clss)[0]        
            
    ###
    00000000  000  000   000  0000000  
    000       000  0000  000  000   000
    000000    000  000 0 000  000   000
    000       000  000  0000  000   000
    000       000  000   000  0000000  
    ###
    
    findPath: ->
        @update() if @find.show()
        @find.key.focus()

    findValue: ->
        @update() if @find.show()
        @find.val.focus()
        
    refocus: =>
        if not document.activeElement.classList.contains 'tree-item'
            setTimeout @focusSelected, 1
            
    onFindApplied: =>
        @selectIndex 0
                            
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
                else if event.mateKey
                    if keycode == 'left'
                        @collapseSubtree true 
                    else
                        @expandSubtree true 
                else
                    @selectedItem()?["select#{_.capitalize(keycode)}"] event
                event.preventDefault()
                
            when '[', ']'
                if event.metaKey and event.altKey
                    if keycode == '['
                        @base.collapseLeaves()
                    else
                        @base.expandLeaves()
                else if event.metaKey
                    if keycode == '['
                        @collapseSubtree()
                    else
                        @expandSubtree()                   
                        
            when 'home' then @selectDelta -@numVisibleLines()
            when 'end'  then @selectDelta  @numVisibleLines()
            when 'up'   then @selectUp event
            when 'down' then @selectDown event
            when 'page up', 'page down'
                n = event.shiftKey and @numVisibleLines() or @numViewLines()
                delta = keycode == 'page up' and -n or n
                @selectDelta delta
                first = _.first @root.children
                last  = _.last @root.children
                if last.value.visibleIndex == @numVisibleLines()-1
                    last.select()
                else
                    first.select()
            # else
            #     log keycode
        
module.exports = View
