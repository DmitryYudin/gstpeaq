cmake_minimum_required(VERSION 3.24)

project(gstpeaq C)

execute_process(
    COMMAND conan install -if conan -g cmake_find_package --build=missing --settings=build_type=Debug ${CMAKE_CURRENT_SOURCE_DIR}/conanfile.txt
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR}/conan)
find_package(glib REQUIRED)
find_package(gst-plugins-base REQUIRED)

include(bootstrap.cmake)

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

target_link_libraries(gstpeaq PUBLIC glib::glib gst-plugins-base::gstreamer-fft-1.0 gst-plugins-base::gstadder)

add_executable(peaq src/peaq.c)
target_link_libraries(peaq PRIVATE glib::glib gst-plugins-base::gstapp)

add_executable(testpeaq src/testpeaq.c)
target_link_libraries(testpeaq PRIVATE gstpeaq)
