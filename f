#!/usr/bin/env coffee
###
00000000
000     
000000  
000     
000     
###

log   = require './log'
find  = require './find'
_     = require 'lodash'
fs    = require 'fs'
chalk = require 'chalk'

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
   .help chalk.blue("Format:\n") + """
    \   #k key
    \   #v value
    \   #o object
    \   #p path
   """
   .parse()

if not fs.existsSync args.file
    log nomnom.getUsage()
    log chalk.red("\ncan't find file: #{chalk.yellow.bold(args.file)}")
    process.exit()

str = fs.readFileSync args.file

if str.length <= 0
    log chalk.red("\nempty file: #{chalk.yellow.bold(args.file)}\n")
    process.exit()        

data = JSON.parse str

if not (data.constructor.name in ['Array', 'Object'])
    log chalk.red("\nno structure in file: #{chalk.yellow.bold(args.file)}\n")
    process.exit()        
    
result = 
    if not args.file? or not args.key? and not args.value? and not args.path?
        _.keysIn(data).map (i) -> [i]
    else if args.path?
        find.path data, args.path
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
