###
000  000000000  00000000  00     00
000     000     000       000   000
000     000     0000000   000000000
000     000     000       000 0 000
000     000     00000000  000   000
###

S     = require 'underscore.string'
chalk = require 'chalk'
_     = require 'lodash'
log   = require './log'
    
class Item

    @valueType  = 0
    @arrayType  = 1
    @objectType = 2

    constructor: (@key, @value, prt) -> 

        if @key == -1
            @mdl = prt
        else
            @parent = prt
            
        @type = switch @value.constructor.name
                when 'Array'  then Item.arrayType
                when 'Object' then Item.objectType
                else Item.valueType
                    
        @children = [] if @isParent()
        @keyIndex = {} if @isObject()
        
    root:     ()      -> @parent?.root() ? @
    model:    ()      -> @root().mdl
    setValue: (value) -> @model().setValue @, value
    remove:   ()      -> @model().remove @
    getValue: ()      -> @value
    typeName: ()      -> 
        switch @type
            when 1 then 'Array'
            when 2 then 'Object'
            else 'Value'
    
    depth:        -> @parent? and (@parent.depth() + 1) or 0
    isArray:      -> @type == Item.arrayType
    isObject:     -> @type == Item.objectType
    isParent:     -> @type != Item.valueType
    hasChildren:  -> @isParent() and (not _.isEmpty(@children))
    
    addChild: (child) -> 
        @keyIndex?[child.key] = @children.length
        @children.push child
        
    delChild: (child) ->
        if @type == Item.objectType
            index = @keyIndex[child.key]
            delete @keyIndex[child.key]
            @children.splice index, 1
            @keyIndex = {}
            for index in [0...@children.length]
                @keyIndex[@children[index].key] = index
        else if @type == Item.arrayType
            index = @children.indexOf child
            @children.splice index, 1
            for index in [0...@children.length]
                @children[index].key = index
                    
    childAt: (keyPath) ->
        keyPath = keyPath.split('.') if _.isString keyPath
        [key, rest] = [_.first(keyPath), _.rest(keyPath)]
        # log 'childAt', keyPath, key, rest, @typeName()
        if @type == Item.arrayType
            index = parseInt(key)
        else
            index = @keyIndex[key]
        if rest.length
            @children[index]?.childAt rest
        else
            @children[index]
        
    keyPath: -> 
        if @parent?.keyPath?
            if @parent.parent?
                pp = @parent.keyPath()
                pp.push @key
                pp
            else
                return [ @key ]
        else
            []
        
    traverse: (func, result=[]) ->
        
        if @isParent()
            for child in @children
                child.traverse func, result
        else 
            if func @key, @value
                result.push @
        return result
        
    inspect: (depth) ->
        indent = S.repeat ' ', 2 #9
        s = S.repeat indent, depth-2
        if not @value?
            v = 'null'
        else if @value.inspect?
            v = @value.inspect depth+1
        else if @isParent()
            v = ''
            if @isArray()
                if @children.length
                    c = @children.map((i)-> i.inspect? and i.inspect(depth+1) or i).join(chalk.gray(',\n'))
                    v += chalk.blue('[\n') + c + '\n' + s + indent + chalk.blue(' ]') 
                else
                    v += chalk.blue('[]')
            else if @isObject()
                if @children.length
                    c = @children.map((i)-> i.inspect? and i.inspect(depth+1) or i).join(chalk.gray(',\n'))
                    v += chalk.magenta('{\n') + c + '\n' + s + indent + chalk.magenta(' }') 
                else
                    v += chalk.magenta('{}')
        else
            v = JSON.stringify @getValue()

        # id = chalk.gray(@id.substr(0,8))
        # id = chalk.gray(@id)
        # id = chalk.gray(@keyPath())
        id = ""
        key = @parent?.isArray() and chalk.blue.bold(@key) or (@parent? and chalk.yellow(@key) or chalk.red.bold(@model().name))
        fetched = @unfetched and " unfetched" or ""
        chalk.gray("#{s} #{id} #{key}: ") + chalk.white.bold(v) + chalk.gray(fetched)
    
module.exports = Item
