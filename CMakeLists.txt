cmake_minimum_required(VERSION 3.14)

project(gstpeaq)

add_compile_definitions(_CRT_SECURE_NO_WARNINGS _USE_MATH_DEFINES)

set(GSTREAMER_ROOT $ENV{GSTREAMER_1_0_ROOT_X86_64})
set(GSTREAMER_INC_PATH
	${GSTREAMER_ROOT}/lib/glib-2.0/include
	${GSTREAMER_ROOT}/include/gstreamer-1.0
	${GSTREAMER_ROOT}/include/glib-2.0
	${GSTREAMER_ROOT}/include/glib-2.0/glib
)
set(GSTREAMER_LIB_PATH
	${GSTREAMER_ROOT}/lib
)
set(GSTREAMER_LIBS
	gstfft-1.0.lib
	gobject-2.0.lib
	glib-2.0.lib
	gstreamer-1.0.lib
	gstbase-1.0.lib
)

add_library(gstpeaq MODULE
    src/earmodel.c
    src/fbearmodel.c
    src/fftearmodel.c
    src/gstpeaq.c
    src/gstpeaqplugin.c
    src/leveladapter.c
    src/modpatt.c
    src/movaccum.c
    src/movs.c
    src/nn.c
)
add_compile_definitions( # from 'vs/gstpeaq.props'
	PRIVATE PACKAGE="gstpeaq"
	PRIVATE PACKAGE_BUGREPORT="martin.holters@hsu-hh.de"
	PRIVATE PACKAGE_NAME="GstPEAQ"
	PRIVATE PACKAGE_STRING="GstPEAQ 0.6.1"
	PRIVATE PACKAGE_URL="http://ant.hsu-hh.de/gstpeaq"
	PRIVATE PACKAGE_VERSION="0.6.1"
	PRIVATE VERSION="0.6.1"
)
include_directories(
	src
	${GSTREAMER_INC_PATH}
)
target_link_libraries(gstpeaq
	${GSTREAMER_LIBS}
)
target_link_directories(gstpeaq
	PRIVATE ${GSTREAMER_LIB_PATH}
)

add_executable(peaq
	src/peaq.c
)
target_link_libraries(peaq
	${GSTREAMER_LIBS}
)
target_link_directories(peaq
	PRIVATE ${GSTREAMER_LIB_PATH}
)

# run.bat:
#   set PATH=%GSTREAMER_1_0_ROOT_X86_64%\bin;%PATH%
#	peaq --gst-plugin-path=%~dsp0 %*
