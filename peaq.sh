#!/bin/bash

export PATH=$(cygpath -m realpath deps/gstreamer/1.0/msvc_x86_64/bin):$PATH
.build/peaq.exe --gst-plugin-load=.build/gstpeaq.dll "$@"
