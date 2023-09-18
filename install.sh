#!/usr/bin/env zsh


xcodebuild \
    -project 'SwiftonizeExec.xcodeproj' \
    -config Release \
    -scheme 'SwiftonizeExec' \
    -archivePath ./archive archive