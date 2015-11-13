###
00000000  000  000   000  0000000  
000       000  0000  000  000   000
000000    000  000 0 000  000   000
000       000  000  0000  000   000
000       000  000   000  0000000  
###

_     = require 'lodash'
fs    = require 'fs'
chalk = require 'chalk'

class find

    @traverse: (node, func, count=-1, keyPath=[], result=[]) =>
        switch node.constructor.name
            when "Array"
                for i in [0...node.length]
                    v = node[i]
                    if v.constructor.name in ["Array", "Object"]
                        keyPath.push i
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

    @keyValue: (node, key, value) => @traverse node, (k,v) => (k == key) and (v == value)
    @key:      (node, key)        => @traverse node, (k,v) => (k == key)
    @value:    (node, value)      => @traverse node, (k,v) => (v == value)
    @keyPath:  (node, keyPath)    =>
        kp = _.clone keyPath
        while kp.length
            node = node[kp.shift()]
        node
        
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
          format: { abbr: 'f', help: 'output format: #{k} for key, #{v} for value' }
          version:{ abbr: 'V', flag: true, help: "show version", hidden: true }
       .parse()

    if args.version
        log '0.1.0'
    else if not args.file? or not args.key? and not args.value?
        log nomnom.getUsage()
    else
        data = JSON.parse fs.readFileSync args.file
        result = 
            if args.key? and args.value?
                find.keyValue data, args.key, args.value
            else if args.key?
                find.key data, args.key
            else
                find.value data, args.value
        for path in result
            k = chalk.gray.bold(path.join('.'))  
            v = chalk.yellow.bold(find.keyPath(data, path))
            if args.format
                s = args.format.replace '#{k}', k
                s = s.replace '#{v}', v
            else
                s = "#{k}: #{v}"
            log chalk.gray s
