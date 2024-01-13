#!/bin/bash

DIR_SCRIPT=$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)

export PATH=$(cygpath $(realpath $DIR_SCRIPT/.deps/gstreamer/1.0/msvc_x86_64/bin)):$PATH
$DIR_SCRIPT/.build/peaq.exe --gst-plugin-load=$DIR_SCRIPT/.build/gstpeaq.dll "$@"
