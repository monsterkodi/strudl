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

    constructor: (@key, @value, parent) -> 
        super
        if @isExpandable()
            @expanded = false

    expand:       => @model().expand @
    collapse: (recursive=false) => @model().collapse @, recursive
    isExpanded:   => @expanded
    isCollapsed:  => not @isExpanded()
    isExpandable: => @isParent()
        
    setValue: (value) => @baseItem.setValue value
    getValue: ()      => @baseItem.getValue()
    
    inspect: (depth) =>
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
                if @hasChildren()
                    c = @children().map((i)-> i instanceof ProxyItem and i.inspect(depth+1) or '').join(chalk.gray(',\n'))
                    v += chalk.blue('[\n') + c + '\n' + s + indent + chalk.blue(' ]') 
                else
                    v += '[]'
            else if @isObject()
                if @hasChildren()
                    c = @children().map((i)-> i instanceof ProxyItem and i.inspect(depth+1) or '').join(chalk.gray(',\n'))
                    v += chalk.magenta('{\n') + c + '\n' + s + indent + chalk.magenta(' }') 
                else
                    v += '{}'
        else
            v = JSON.stringify @getValue()

        id = ""
        key = @parent?.isArray() and chalk.blue.bold(@key) or (@parent? and chalk.yellow(@key) or chalk.red.bold(@model().name))
        chalk.gray("#{s} #{id} #{key}: ") + chalk.white.bold(v)

module.exports = ProxyItem
