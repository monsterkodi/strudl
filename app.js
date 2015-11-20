var BrowserWindow, app;

app = require('app');

BrowserWindow = require('browser-window');

app.on('ready', function() {
    var cwd, win;
    cwd = __dirname
    win = new BrowserWindow({
        dir: cwd,
        preloadWindow: true,
        resizable: true,
        frame: true,
        show: true,
        center: false
    });
    win.loadURL("file://" + cwd + "/win.html");
});
