###
00000000   00000000    0000000   000   000  000   000  000  000000000  00000000  00     00
000   000  000   000  000   000   000 000    000 000   000     000     000       000   000
00000000   0000000    000   000    00000      00000    000     000     0000000   000000000
000        000   000  000   000   000 000      000     000     000     000       000 0 000
000        000   000   0000000   000   000     000     000     000     00000000  000   000
###

S     = require 'underscore.string'
chalk = require 'chalk'
log   = require './log'
Item  = require './item'

class ProxyItem extends Item

    constructor: (@key, @value, prt) -> 

        if @key == -1
            @mdl = prt
        else
            @parent = prt
            
        @type = @value.type
        @numVisible = 1
                    
        @children = []    if @isParent()
        @keyIndex = {}    if @isObject()
        @expanded = false if @isExpandable()

    setValue: (value)      -> @value.setValue value
    getValue: ()           -> @value.getValue()
    remove:   ()           -> @value.remove()
    insert:   (key, value) -> @value.insert key, value
    depth:                 -> @value.depth()
    dataItem: ()           -> @value.dataItem?() ? @value
    
    changeVisible: (delta) -> @eachAncestor (i) -> i.numVisible += delta
        
    visibleIndex: -> 
        return -1 if not @parent?
        @parent.visibleIndex() + @indexInParent() + 1
        
    visibleAtIndex: (i) ->
        for child in @children
            if i < child.numVisible
                if i == 0
                    return child
                else
                    return child.visibleAtIndex i-1
            else # i >= child.numVisible
                i -= child.numVisible
        return null
    
    toggle: () ->
        if @isExpanded()
            @collapse()
        else
            @expand()
    
    expand: (recursive=false) -> 
        if @value instanceof ProxyItem
            @value.expand recursive
        else
            @model().expand @, recursive
            
    collapse: (recursive=false) -> 
        if @value instanceof ProxyItem
            @value.collapse recursive
        else
            @model().collapse @, recursive
            
    isExpanded: -> 
        if @value instanceof ProxyItem
            @value.isExpanded()
        else
            @expanded
            
    isCollapsed:  -> not @isExpanded()
    isExpandable: -> @isParent()
            
    inspect: (depth) ->

        indent = S.repeat ' ', 2
        s = S.repeat indent, depth-2

        if not @value?
            v = 'null'
        else if @isExpandable()
            if @isCollapsed()
                v = '▶ '
            else
                v = '▽ '
                if @isArray() 
                    if @children.length
                        c = @children.map((i)-> i instanceof ProxyItem and i.inspect(depth+1) or '').join(chalk.gray(',\n'))
                        v += chalk.blue('[\n') + c + '\n' + s + indent + chalk.blue(' ]') 
                    else
                        v += '[]'
                else if @isObject()
                    if @children.length
                        c = @children.map((i)-> i instanceof ProxyItem and i.inspect(depth+1) or '').join(chalk.gray(',\n'))
                        v += chalk.magenta('{\n') + c + '\n' + s + indent + chalk.magenta(' }') 
                    else
                        v += '{}'
        else
            v = JSON.stringify @getValue()

        id = ""
        key = @parent?.isArray() and chalk.blue.bold(@key) or (@parent? and chalk.yellow(@key) or chalk.red.bold(@model().name))
        chalk.gray("#{s} #{id} #{key}: ") + chalk.white.bold(v)

module.exports = ProxyItem
