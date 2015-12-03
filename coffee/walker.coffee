
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
root = "/Users/kodi"
walk = walkDir root, 
    "max_depth": Infinity
    
walk.ignore ["/Volumes", "/Users/kodi/Library/Developer/Shared/Documentation/DocSets"]
    
dirs = 
    "#{root}": 
        files: []
        dirs: []
        size: 0
        name: root
        path: ''
        
shorten = (p, l=80) ->
    if p.length <= l then return p
    p.substr(0,l-3) + '...'
        
calcSize = (dirname) ->
    d = dirs[dirname]
    if d?
        for file in d.files
            d.size += file.size
        for dir in d.dirs
            if dirname == '/'
                d.size += calcSize '/' + dir
            else
                d.size += calcSize dirname + '/' + dir
        return d.size
    log '???', dirname
    0
    
walk.on 'directory', (dirname, stat) ->
    log chalk.blue.bold dirname if verbose
    parent = dirs[path.dirname dirname]
    name = path.basename dirname
    parent.dirs.push name
    dirs[dirname] = 
        files: []
        dirs:  []
        size:  0   
        name:  name
        path:  dirname
        
    if not verbose
        process.stdout.clearLine()
        process.stdout.cursorTo(0)
        process.stdout.write shorten dirname

walk.on 'file', (filename, stat) ->
    dirname = path.dirname filename
    log chalk.magenta dirname if verbose
    parent = dirs[dirname]
    parent.files.push 
        name: path.basename filename
        size: stat.size
                
walk.on 'end', ->
    process.stdout.clearLine()
    process.stdout.cursorTo(0)
    log "#{Object.keys(dirs).length} dirs parsed in #{timeSinceStart()}"
    calcSize root
    log 'total size:', dirs[root].size
    
    fs.writeFileSync resolve('~/Projects/strudl/data/home.json'), JSON.stringify(dirs)
    
    log "json saved at #{timeSinceStart()}"
    
