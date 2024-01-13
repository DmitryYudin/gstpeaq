cmake_minimum_required(VERSION 3.24)

project(gstpeaq C)

include(bootstrap.cmake)

set(GST_SDK_PATH ${CMAKE_CURRENT_SOURCE_DIR}/.deps/gstreamer/1.0/msvc_x86_64)
include_directories(${GST_SDK_PATH}/include/gstreamer-1.0)
include_directories(${GST_SDK_PATH}/include/glib-2.0)
include_directories(${GST_SDK_PATH}/lib/glib-2.0/include)
link_directories(${GST_SDK_PATH}/lib)
link_libraries(glib-2.0.lib gobject-2.0.lib gstreamer-1.0.lib gstbase-1.0.lib gstfft-1.0.lib)

add_library(gstpeaq SHARED
    src/earmodel.c
    src/earmodel.h
    src/fbearmodel.c
    src/fbearmodel.h
    src/fftearmodel.c
    src/fftearmodel.h
    src/gstpeaq.c
    src/gstpeaq.h
    src/gstpeaqplugin.c
    src/leveladapter.c
    src/leveladapter.h
    src/modpatt.c
    src/modpatt.h
    src/movaccum.c
    src/movaccum.h
    src/movs.c
    src/movs.h
    src/nn.c
    src/nn.h
    src/settings.h
)
add_compile_definitions(_USE_MATH_DEFINES)
add_compile_definitions(
    PACKAGE="gstpeaq"
    PACKAGE_BUGREPORT="martin.holters@hsu-hh.de"
    PACKAGE_NAME="GstPEAQ"
    PACKAGE_STRING="GstPEAQ 0.6.1"
    PACKAGE_URL="http://ant.hsu-hh.de/gstpeaq"
    PACKAGE_VERSION="0.6.1"
    VERSION="0.6.1"
)

add_executable(peaq src/peaq.c)
