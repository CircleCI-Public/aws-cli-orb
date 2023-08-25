#!/bin/sh
detect_os(){

    # Platform check
    if uname -a | grep "Darwin"; then
        SYS_ENV_PLATFORM=macos
    elif uname -s | grep "Linux"; then
        SYS_ENV_PLATFORM=linux
    elif uname -s | grep "MSYS"; then
        SYS_ENV_PLATFORM=windows
    else
        echo "This platform appears to be unsupported."
        uname -a
        exit 1
    fi

    export SYS_ENV_PLATFORM

}
