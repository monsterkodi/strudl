#!/usr/bin/env coffee
###
00000000  000  000   000  0000000  
000       000  0000  000  000   000
000000    000  000 0 000  000   000
000       000  000  0000  000   000
000       000  000   000  0000000  
###

_         = require 'lodash'
fs        = require 'fs'
chalk     = require 'chalk'

class find

    @traverse: (node, func, count=-1, keyPath=[], result=[]) =>
        switch node.constructor.name
            when "Array"
                for i in [0...node.length]
                    v = node[i]
                    keyPath.push i
                    if func i,v
                        result.push _.clone(keyPath, true)
                        return result if count > 0 and result.length >= count                    
                    if v.constructor.name in ["Array", "Object"]
                        @traverse v, func, count, keyPath, result
                    keyPath.pop()
            when "Object"
                for k,v of node
                    keyPath.push k
                    if func k,v
                        result.push _.clone(keyPath, true)
                        return result if count > 0 and result.length >= count
                    if v.constructor.name in ["Array", "Object"]
                        @traverse v, func, count, keyPath, result
                    keyPath.pop()
        return result

    @keyValue: (node, key, value) => @traverse node, (k,v) => @match(k, key) and @match(v, value)
    @key:      (node, key)        => @traverse node, (k,v) => @match(k, key)
    @value:    (node, value)      => @traverse node, (k,v) => @match(v, value)
    @keyPath:  (node, keyPath)    =>
        kp = _.clone keyPath
        while kp.length
            node = node[kp.shift()]
            return if not node?
        node
        
    @match: (a,b) =>
        if _.isString(a) and _.isString(b) and b.indexOf('*') >= 0
            p = _.clone(b)
            p = p.replace /\*/g, '.*'
            p = "^"+p+"$"
            a.match(new RegExp(p))?.length
        else
            a == b
        
module.exports = find

if process.mainModule == module
    
    log = require './log'
    
    nomnom = require("nomnom")
    args = nomnom
       .script("find")
       .options
          file:
             position: 0
             help: "the json file to search in"
             list: false
             required: false
          key:    { abbr: 'k', help: 'key to search' }
          value:  { abbr: 'v', help: 'value to search' }
          path:   { abbr: 'p', help: 'path to search' }
          format: { abbr: 'f', help: 'output format' }
          version:{ abbr: 'V', flag: true, help: "show version", hidden: true }
       .help chalk.blue("Format:\n") + """
        \   #k key
        \   #v value
        \   #o object
        \   #p path
       """
       .parse()

    if args.version
        log '0.1.0'
    else
        data = JSON.parse fs.readFileSync args.file
        result = 
            if not args.file? or not args.key? and not args.value? and not args.path?
                _.keysIn(data).map (i) -> [i]
            else if args.path?
                [new String(args.path).split '.']
            else if args.key? and args.value?
                find.keyValue data, args.key, args.value
            else if args.key?
                find.key data, args.key
            else
                find.value data, args.value
        for path in result
            p = chalk.gray.bold(path.join('.'))  
            k = chalk.magenta.bold(_.last path)
            value = find.keyPath(data, path)
            if value?.constructor.name in ['Array', 'Object']
                value = JSON.stringify value, null, '  '
            v = chalk.yellow.bold(value)
            if args.format
                s = args.format
                s = s.replace '#k', k
                s = s.replace '#p', p
                s = s.replace '#v', v
                if args.format.indexOf('#o') >= 0
                    path.pop()
                    o = JSON.stringify find.keyPath(data, path), null, '  '
                    s = s.replace '#o', o
            else
                s = "#{p}: #{v}"
            log chalk.gray s
