###
00000000  000  000   000  0000000  
000       000  0000  000  000   000
000000    000  000 0 000  000   000
000       000  000  0000  000   000
000       000  000   000  0000000  
###

_ = require 'lodash'

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
        
module.exports = find
