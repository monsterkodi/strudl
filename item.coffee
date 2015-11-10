###
000  000000000  00000000  00     00
000     000     000       000   000
000     000     0000000   000000000
000     000     000       000 0 000
000     000     00000000  000   000
###

S     = require 'underscore.string'
chalk = require 'chalk'
uuid  = require 'uuid'
_     = require 'lodash'
log   = require './log'
    
class Item

    constructor: (@model, @key, @value, @parent) -> 
        @id = uuid.v4()
        @parent?.value[@key] = @
            
    setValue: (value) => @model.setValue @, value
    
    depth:       => @parent? and (@parent.depth() + 1) or 0
    isArray:     => _.isArray @value
    isObject:    => _.isObject @value
    children:    => _.valuesIn @value
    hasChildren: => (@isArray() or @isObject()) and not _.isEmpty @value

    get: (keyPath) =>
        split = keyPath.split '.'
        [key, rest] = [split.shift(), split]
        if rest?.length
            @value[key].get rest.join('.')
        else
            @value[key]
        
    keyPath: => 
        if @parent?
            if @parent.parent?
                @parent.keyPath() + '.' + @key
            else
                @key
        else
            ''
        
    inspect: (depth) =>
        indent = S.repeat ' ', 9
        s = S.repeat indent, depth-2
        if not @value?
            v = 'null'
        else if @value.inspect?
            v = @value.inspect depth+1
        else if @isArray()
            if @hasChildren()
                c = @children().map((i)-> i.inspect? and i.inspect(depth+1) or i).join(chalk.gray(',\n'))
                v = chalk.blue('[\n') + c + '\n' + s + indent + chalk.blue(' ]') 
            else
                v = chalk.blue('[]')
        else if @isObject()
            if @hasChildren()
                c = @children().map((i)-> i.inspect? and i.inspect(depth+1) or i).join(chalk.gray(',\n'))
                v = chalk.magenta('{\n') + c + '\n' + s + indent + chalk.magenta(' }') 
            else
                v = chalk.magenta('{}')
        else
            v = JSON.stringify @value

        # id = chalk.gray(@id.substr(0,8))
        # id = chalk.gray(@id)
        id = chalk.gray(@keyPath())
        # id = ""
        chalk.gray("#{s} #{id} #{chalk.yellow(@key)}: ") + chalk.white.bold(v)
    
module.exports = Item
