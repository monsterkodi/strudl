###
000  000000000  00000000  00     00
000     000     000       000   000
000     000     0000000   000000000
000     000     000       000 0 000
000     000     00000000  000   000
###

_     = require 'lodash'
S     = require 'underscore.string'
chalk = require 'chalk'
log   = require './tools/log'
    
class Item

    @valueType  = 0
    @arrayType  = 1
    @objectType = 2

    constructor: (@key, @value, prt) -> 

        @numDescendants = 0
        if @key == -1
            @mdl = prt
        else
            @parent = prt
        
        if @value?
            @type = switch @value.constructor.name
                    when 'Array'  then Item.arrayType
                    when 'Object' then Item.objectType
                    else @value.type ? Item.valueType
        else
            @type = Item.valueType
                                        
        @children = [] if @isParent()
        @keyIndex = {} if @isObject()
        
    root:    -> @parent?.root() ? @
    model:   -> @root().mdl
    
    ###
    0000000    00000000  00000000   000000000  000   000
    000   000  000       000   000     000     000   000
    000   000  0000000   00000000      000     000000000
    000   000  000       000           000     000   000
    0000000    00000000  000           000     000   000
    ###
    
    isTop:   -> @parent == @root()
    topItem: -> @isTop() and @ or @parent?.topItem()
    depth:   -> @parent? and (@parent.depth() + 1) or 0

    ###
    00000000  0000000    000  000000000
    000       000   000  000     000   
    0000000   000   000  000     000   
    000       000   000  000     000   
    00000000  0000000    000     000   
    ###
    
    getValue:              -> @value
    setValue: (value)      -> @model().setValue @, value
    
    remove:   ()           -> @model().remove @
    insert:   (key, value) -> @model().insert @, key, value
    
    ###
    000000000  000   000  00000000   00000000
       000      000 000   000   000  000     
       000       00000    00000000   0000000 
       000        000     000        000     
       000        000     000        00000000
    ###
    
    typeName: -> 
        switch @type
            when 1 then 'Array'
            when 2 then 'Object'
            else 'Value'
    
    isArray:     -> @type == Item.arrayType
    isObject:    -> @type == Item.objectType
    
    ###
     0000000  000   000  000  000      0000000    00000000   00000000  000   000
    000       000   000  000  000      000   000  000   000  000       0000  000
    000       000000000  000  000      000   000  0000000    0000000   000 0 000
    000       000   000  000  000      000   000  000   000  000       000  0000
     0000000  000   000  000  0000000  0000000    000   000  00000000  000   000
    ###
    
    isParent:    -> @type != Item.valueType
    hasChildren: -> @isParent() and (not _.isEmpty(@children))
            
    addChild: (child) -> 
        index = switch @type 
            when Item.objectType 
                @keyIndex[child.key] = @children.length
                @children.length
            when Item.arrayType  
                parseInt(child.key)
        @insertChild child, index
        
    insertChild: (child, index) ->

        if index == @children.length
            @children.push child
        else    
            @children.splice index, 0, child
        
            if @type == Item.arrayType
                for i in [index+1...@children.length]
                    @children[i].key = i
        
    delChild: (child) ->
        if @type == Item.objectType
            index = @keyIndex[child.key]
            @children.splice index, 1
            @updateIndices()
        else if @type == Item.arrayType
            index = @children.indexOf child
            @children.splice index, 1
            @updateIndices()

    updateDescendants: () ->
        @numDescendants = 1
        if @isParent()
            for child in @children
                @numDescendants += child.updateDescendants()
        @numDescendants

    ###
    000  000   000  0000000    00000000  000   000
    000  0000  000  000   000  000        000 000 
    000  000 0 000  000   000  0000000     00000  
    000  000  0000  000   000  000        000 000 
    000  000   000  0000000    00000000  000   000
    ###
    
    indexInParent: ->
        if @parent?.children?.length < 1000
            return @parent.children.indexOf @
        switch @parent?.type
            when Item.arrayType then parseInt(@key)
            when Item.objectType then @parent.keyIndex[@key]
            else 0
    
    lastChild: ->
        if @children?.length
            return @children[@children.length-1].lastChild()
        @
                
    updateIndices: ->
        if @type == Item.objectType
            @keyIndex = {}    
            for index in [0...@children.length]
                @keyIndex[@children[index].key] = index
        else if @type == Item.arrayType
            for index in [0...@children.length]
                @children[index].key = index
            
    ###
    000   000  00000000  000   000  00000000    0000000   000000000  000   000
    000  000   000        000 000   000   000  000   000     000     000   000
    0000000    0000000     00000    00000000   000000000     000     000000000
    000  000   000          000     000        000   000     000     000   000
    000   000  00000000     000     000        000   000     000     000   000
    ###
            
    childAt: (keyPath) ->
        keyPath = keyPath.split('.') if _.isString keyPath
        [key, rest] = [_.first(keyPath), _.rest(keyPath)]
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
        
    ###
    000000000  00000000    0000000   000   000  00000000  00000000    0000000  00000000
       000     000   000  000   000  000   000  000       000   000  000       000     
       000     0000000    000000000   000 000   0000000   0000000    0000000   0000000 
       000     000   000  000   000     000     000       000   000       000  000     
       000     000   000  000   000      0      00000000  000   000  0000000   00000000
    ###
            
    eachAncestor: (func) ->
        func @
        @parent?.eachAncestor func
        
    traverse: (func, result=[], test=false) ->

        if test
            if func @
                result.push @
        
        if @isParent()
            for child in @children
                child.traverse func, result, true

        return result
        
    findFirst: (func, test=false) ->
        if test
            if func @
                return @
        if @children?
            for child in @children
                if found = child.findFirst func, true
                    return found
        null
        
    ###
    000  000   000   0000000  00000000   00000000   0000000  000000000
    000  0000  000  000       000   000  000       000          000   
    000  000 0 000  0000000   00000000   0000000   000          000   
    000  000  0000       000  000        000       000          000   
    000  000   000  0000000   000        00000000   0000000     000   
    ###
        
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
