
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
root = "/Users/kodi/Projects"
walk = walkDir root, 
    "max_depth": Infinity
    
walk.ignore ["/Volumes", "/Users/kodi/Library/Developer/Shared/Documentation/DocSets"]
    
dirs = 
    files: {}
    dirs: {}
    size: 0
    name: path.basename root
    path: root
dpth = root.split(path.sep).length
        
shorten = (p, l=80) ->
    if p.length <= l then return p
    p.substr(0,l-3) + '...'
        
getDir = (p) ->
    s = p.split path.sep
    s = s.slice dpth
    c = dirs
    while s.length
        c = c.dirs[s.shift()]
    c
    
calcSize = (dirname) ->
    if d?
        for k,file of d.files
            d.size += file.size
        for k,dir of d.dirs
            if dirname == '/'
                d.size += calcSize('/' + dir.name)
            else
                d.size += calcSize(dirname + '/' + dir.name)
        return d.size
    log '???', dirname
    0
        
walk.on 'directory', (dirname, stat) ->
    log chalk.blue.bold dirname if verbose
    parent = getDir path.dirname dirname
    name = path.basename dirname
    parent.dirs[name] =
        files: {}
        dirs:  {}
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
    parent = getDir dirname
    name = path.basename filename
    parent.files[name] =
        name: name
        size: stat.size
                
walk.on 'end', ->
    process.stdout.clearLine()
    process.stdout.cursorTo(0)
    log "#{Object.keys(dirs).length} dirs parsed in #{timeSinceStart()}"
    calcSize root
    log 'total size:', dirs.size
    
    fs.writeFileSync resolve('~/Projects/strudl/data/projects_tree.json'), JSON.stringify(dirs)
    
    log "json saved at #{timeSinceStart()}"
    
