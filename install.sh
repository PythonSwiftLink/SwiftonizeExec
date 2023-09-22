#!/usr/bin/env zsh

BIN=/usr/local/bin/Swiftonize

# git clone https://github.com/PythonSwiftLink/SwiftonizeExec
# cd SwiftonizeExec
xcodebuild \
    -project 'SwiftonizeExec.xcodeproj' \
    -config Release \
    -scheme 'SwiftonizeExec' \
    -archivePath ./archive archive

sudo mkdir $BIN
sudo cp -Rf python_stdlib $BIN/python_stdlib
sudo cp -Rf python-extra $BIN/python-extra
sudo cp -f archive.xcarchive/Products/usr/local/bin/SwiftonizeExec $BIN/SwiftonizeExec
