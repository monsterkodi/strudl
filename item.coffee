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
            
    fetch:    ()      => @model.fetchItem @
    setValue: (value) => @model.setValue @, value
    getValue: ()      => @value
    
    depth:        => @parent? and (@parent.depth() + 1) or 0
    isArray:      => _.isArray @value
    isObject:     => _.isObject(@value) and not (@value instanceof Item)
    isParent:     => @isArray() or @isObject()
    type:         => 
        return 'Array'  if @isArray()
        return 'Object' if @isObject()
        return 'Value'
    hasChildren:  => @isParent() and not _.isEmpty @value
    children:     => @hasChildren() and _.valuesIn @value
    keys:         => @isObject() and Object.keys(@value) or [0...@value.length].map (v) -> new String(v)
    
    childAt: (keyPath) =>
        keyPath = keyPath.split('.') if _.isString keyPath
        [key, rest] = [_.first(keyPath), _.rest(keyPath)]
        log 'childAt', keyPath, key, rest
        if rest.length
            @value[key].childAt rest
        else
            @value[key]
        
    keyPath: => 
        if @parent?
            if @parent.parent?
                @parent.keyPath().append @key
            else
                [@key]
        else
            []
        
    inspect: (depth) =>
        indent = S.repeat ' ', 2 #9
        s = S.repeat indent, depth-2
        if not @value?
            v = 'null'
        else if @value.inspect?
            v = @value.inspect depth+1
        else if @isParent()
            v = ''
            if @isArray()
                if @hasChildren()
                    c = @children().map((i)-> i.inspect? and i.inspect(depth+1) or i).join(chalk.gray(',\n'))
                    v += chalk.blue('[\n') + c + '\n' + s + indent + chalk.blue(' ]') 
                else
                    v += chalk.blue('[]')
            else if @isObject()
                if @hasChildren()
                    c = @children().map((i)-> i.inspect? and i.inspect(depth+1) or i).join(chalk.gray(',\n'))
                    v += chalk.magenta('{\n') + c + '\n' + s + indent + chalk.magenta(' }') 
                else
                    v += chalk.magenta('{}')
        else
            v = JSON.stringify @getValue()

        # id = chalk.gray(@id.substr(0,8))
        # id = chalk.gray(@id)
        # id = chalk.gray(@keyPath())
        id = ""
        key = @parent?.isArray() and chalk.blue.bold(@key) or (@parent? and chalk.yellow(@key) or chalk.red.bold(@model.name))
        fetched = @unfetched and " unfetched" or ""
        chalk.gray("#{s} #{id} #{key}: ") + chalk.white.bold(v) + chalk.gray(fetched) #+ ' ' + @type()
    
module.exports = Item
