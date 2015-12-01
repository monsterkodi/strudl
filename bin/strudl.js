
/*
 0000000  000000000  00000000   000   000  0000000    000    
000          000     000   000  000   000  000   000  000    
0000000      000     0000000    000   000  000   000  000    
     000     000     000   000  000   000  000   000  000    
0000000      000     000   000   0000000   0000000    0000000
 */
var app, cp, download, exec, fs, log, open, process, src, tar, tgz, unpack, version;

fs = require('fs');

process = require('process');

tar = require('tarball-extract');

download = require('download');

cp = require('child_process');

exec = cp.exec;

log = console.log;

app = __dirname + "/strudl.app";

tgz = app + ".tgz";

open = function() {
  var args;
  args = process.argv.slice(2).join(" ");
  return exec(("open -a " + app + " ") + args);
};

unpack = function() {
  log("unpacking " + tgz + " ...");
  return tar.extractTarball(tgz, __dirname, function(err) {
    if (err) {
      return log(err);
    } else {
      return open();
    }
  });
};

if (!fs.existsSync(app)) {
  log('app not found ...');
  if (!fs.existsSync(tgz)) {
    version = require('../package.json').version;
    src = "https://github.com/monsterkodi/strudl/releases/download/v" + version + "/strudl.app.tgz";
    log("downloading from github (this will take a while) ...");
    log(src);
    new download().get(src).dest(__dirname).run(function(err, files) {
      if (err) {
        return log(err);
      } else {
        console.log('downloaded');
        return unpack();
      }
    });
  } else {
    unpack();
  }
} else {
  open();
}
