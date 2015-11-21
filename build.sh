#!/usr/bin/env bash
node_modules/electron-packager/cli.js . strudl --overwrite --platform=darwin --arch=x64 --version=0.35.1 --app-version=0.1.0 --app-bundle-id=net.monsterkodi.strudl --ignore=node_modules/electron-prebuild --icon=img/strudl.icns
mv strudl-darwin-x64/strudl.app .
rm -rf strudl-darwin-x64
