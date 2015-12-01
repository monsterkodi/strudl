###
 0000000  000000000  00000000   000   000  0000000    000    
000          000     000   000  000   000  000   000  000    
0000000      000     0000000    000   000  000   000  000    
     000     000     000   000  000   000  000   000  000    
0000000      000     000   000   0000000   0000000    0000000
###

fs      = require 'fs'
process = require 'process'
tar     = require 'tarball-extract'
cp      = require 'child_process'
exec    = cp.exec
log     = console.log

app = "#{__dirname}/Strudl.app"
tgz = "#{app}.tgz"

unpack = () ->
    log "unpacking #{tgz} ..."
    tar.extractTarball tgz, __dirname, (err) -> 
        log err if err
        open()
    
open = () ->
    args = process.argv.slice(2).join " "
    exec "open -a #{app} " + args

if not fs.existsSync app
    log 'app not found ...'
    if not fs.existsSync tgz
        src = 'https://media.githubusercontent.com/media/monsterkodi/strudl/master/bin/Strudl.app.tgz'
        log "downloading tgz from github (this will take a while) ..."
        tar.extractTarballDownload src , tgz, __dirname, {}, (err, result) ->
            if err
                log err
            else
                console.log 'downloaded'
                open()
    else
        unpack()
else
    open()
    
