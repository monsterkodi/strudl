###
 0000000  000000000  00000000   000   000  0000000    000    
000          000     000   000  000   000  000   000  000    
0000000      000     0000000    000   000  000   000  000    
     000     000     000   000  000   000  000   000  000    
0000000      000     000   000   0000000   0000000    0000000
###

fs       = require 'fs'
process  = require 'process'
tar      = require 'tarball-extract'
download = require 'download'
cp       = require 'child_process'
exec     = cp.exec
log      = console.log

app = "#{__dirname}/strudl.app"
tgz = "#{app}.tgz"

open = () ->
    args = process.argv.slice(2).join " "
    exec "open -a #{app} " + args

unpack = () ->
    log "unpacking #{tgz} ..."
    tar.extractTarball tgz, __dirname, (err) -> 
        if err
            log err 
        else
            open()
    
if not fs.existsSync app
    log 'app not found ...'
    if not fs.existsSync tgz
        version = require('../package.json').version
        src = "https://github.com/monsterkodi/strudl/releases/download/v#{version}/strudl.app.tgz"
        log "downloading from github (this will take a while) ..."
        log src
        new download()
            .get src
            .dest __dirname
            .run (err, files) ->
                if err
                    log err
                else
                    console.log 'downloaded'
                    unpack()
    else
        unpack()
else
    open()
    
