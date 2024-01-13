#!/bin/bash

set -eu

download_and_extract() {
    local package=$1
    if [[ ! -f $package ]]; then
        aria2c $URL/windows/$VER/msvc/$package -o $package.tmp
        mv $package.tmp $package
    fi
    MSYS2_ARG_CONV_EXCL="*" msiexec.exe /a $package /qb TARGETDIR="$(cygpath -w "$(realpath .deps)")"
}

URL=https://gstreamer.freedesktop.org/data/pkg
VER=1.18.3
ARCH=x86_64

download_and_extract gstreamer-1.0-msvc-$ARCH-$VER.msi
download_and_extract gstreamer-1.0-devel-msvc-$ARCH-$VER.msi
