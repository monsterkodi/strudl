
/*
 0000000  000000000  00000000   000   000  0000000    000    
000          000     000   000  000   000  000   000  000    
0000000      000     0000000    000   000  000   000  000    
     000     000     000   000  000   000  000   000  000    
0000000      000     000   000   0000000   0000000    0000000
 */
var app, cp, exec, fs, log, open, process, src, tar, tgz, unpack;

fs = require('fs');

process = require('process');

tar = require('tarball-extract');

cp = require('child_process');

exec = cp.exec;

log = console.log;

app = __dirname + "/strudl.app";

tgz = app + ".tgz";

unpack = function() {
  log("unpacking " + tgz + " ...");
  return tar.extractTarball(tgz, __dirname, function(err) {
    if (err) {
      log(err);
    }
    return open();
  });
};

open = function() {
  var args;
  args = process.argv.slice(2).join(" ");
  return exec(("open -a " + app + " ") + args);
};

if (!fs.existsSync(app)) {
  log('app not found ...');
  if (!fs.existsSync(tgz)) {
    src = 'https://media.githubusercontent.com/media/monsterkodi/strudl/master/bin/strudl.app.tgz';
    log("downloading tgz from github (this will take a while) ...");
    tar.extractTarballDownload(src, tgz, __dirname, {}, function(err, result) {
      if (err) {
        return log(err);
      } else {
        console.log('downloaded');
        return open();
      }
    });
  } else {
    unpack();
  }
} else {
  open();
}
