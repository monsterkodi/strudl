
resolve = require './tools/resolve'
walkDir = require 'walkdir'
fs      = require 'fs'
moment  = require 'moment'
chalk   = require 'chalk'
path    = require 'path'
log     = console.log

jsonStr = (a) -> JSON.stringify a, null, " "

startTime = moment()
timeSinceStart = () -> moment().subtract(startTime).format('m [m] s [s]')

verbose = false
root = "/"
walk = walkDir root, 
    "max_depth": Infinity
    
walk.ignore ["/Volumes", "/Users/kodi/Library/Developer/Shared/Documentation/DocSets"]
    
dirs = {}
dpth = root.split(path.sep).length
        
shorten = (p, l=80) ->
    if p.length <= l then return p
    p.substr(0,l-3) + '...'
        
getDir = (p) ->
    s = p.split path.sep
    s = s.slice dpth
    c = dirs
    while s.length
        c = c[s.shift()]
    c
            
walk.on 'directory', (dirname, stat) ->
    log chalk.blue.bold dirname if verbose
    parent = getDir path.dirname dirname
    name = path.basename dirname
    parent[name] = {}
        
    if not verbose
        process.stdout.clearLine()
        process.stdout.cursorTo(0)
        process.stdout.write shorten dirname

walk.on 'file', (filename, stat) ->
    dirname = path.dirname filename
    log chalk.magenta dirname if verbose
    parent = getDir dirname
    name = path.basename filename
    parent[name] = stat.size
                
walk.on 'end', ->
    process.stdout.clearLine()
    process.stdout.cursorTo(0)
    log "#{Object.keys(dirs).length} dirs parsed in #{timeSinceStart()}"
    
    fs.writeFileSync resolve('~/Projects/strudl/data/root_dict.json'), JSON.stringify(dirs)
    
    log "json saved at #{timeSinceStart()}"
    
