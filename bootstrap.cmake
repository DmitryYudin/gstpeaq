#
# This file defines two pairs of macro: {x86, x64} and {ARM, ARM64} based on toolchain settings.
#
# CMAKE_SYSTEM_NAME - Valid names can be identified from the content of 'Modules/Platform' folder: AIX, Android, Apple, ...
#           as well as a set of available compilers visible throught 'Platform/{CMAKE_SYSTEM_NAME}-${CompilerId}' files.
# The most usefull 'CMAKE_SYSTEM_NAME's to match 'Build.gn' are:
#           android <=> Android
#             linux <=> Linux
#               win <=> Windows
#               ios <=> iOS
#               mac <=> Darwin
#               ??? <=> tvOS, watchOS
#
# A set of supported languages are given by 'Modules/CMakeDetermine${Lang}Compiler.cmake' files: ASM-ATT ASM_MASM ASM_NASM ASM
#           C CSharp CUDA CXX Fortran HIP ISPC Java OBJC OBJCXX RC Swift
# 
# The are lot of compilers supported (see 'Modules/CMakeCompilerIdDetection.cmake'): ADSP AppleClang ARMCC ARMClang Borland Bruce
#           Clang Comeau Compaq Cray Embarcadero Fujitsu FujitsuClang GHS GNU HP IAR Intel IntelLLVM NVHPC NVIDIA MSVC OpenWatcom
#           PathScale PGI SCO SDCC SunPro TI TinyCC VisualAge Watcom XL XLClang zOS
#
# https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/How-To-Write-Platform-Checks: 
# (old school, "soft" deprecated)
#           UNIX   : is TRUE on all UNIX-like OS's, including Apple OS X and CygWin
#           WIN32  : is TRUE on Windows. Prior to 2.8.4 this included CygWin
#           APPLE  : is TRUE on Apple systems. Note this does not imply the system is Mac OS X,
#                    only that APPLE is #defined in C/C++ header files.
#           MINGW  : is TRUE when using the MinGW compiler in Windows
#           MSYS   : is TRUE when using the MSYS developer environment in Windows
#           CYGWIN : is TRUE on Windows when using the CygWin version of cmake
#
if (CMAKE_CONFIGURATION_TYPES) # https://stackoverflow.com/questions/31661264/cmake-generators-for-visual-studio-do-not-set-cmake-configuration-types
    if(CMAKE_BUILD_TYPE)
        set(CMAKE_CONFIGURATION_TYPES "${CMAKE_BUILD_TYPE}" CACHE STRING "${CMAKE_BUILD_TYPE} only" FORCE)
    endif()
endif()

# System architecture detection
string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" SYSPROC)
set(X86_ALIASES x86 i386 i686 x86_64 amd64)
set(ARM_ALIASES armeabi-v7a armv7-a aarch64 arm64-v8a)
list(FIND X86_ALIASES "${SYSPROC}" X86MATCH)
list(FIND ARM_ALIASES "${SYSPROC}" ARMMATCH)
if ("${SYSPROC}" STREQUAL "" OR X86MATCH GREATER "-1")
    set(X86 1)
    if ("${CMAKE_SIZEOF_VOID_P}" MATCHES 8)
        set(X64 1)
    else()
        set(X64 0)
    endif()
elseif (ARMMATCH GREATER "-1")
    set(ARM 1)
    if ("${CMAKE_SIZEOF_VOID_P}" MATCHES 8)
        set(ARM64 1)
    else()
        set(ARM64 0)
    endif()
else()
    message(FATAL_ERROR "CMAKE_SYSTEM_PROCESSOR value `${CMAKE_SYSTEM_PROCESSOR}` is unknown\n"
                        "Please add this value near ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE}")
endif()

# https://cmake.org/cmake/help/latest/manual/cmake-variables.7.html
string(REGEX MATCH "^[0-9]+\\.[0-9]+" compiler_ver "${CMAKE_C_COMPILER_VERSION}")
set(info "target=${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
if (CMAKE_C_COMPILER_FRONTEND_VARIANT)
    set(info "${info} compiler=${CMAKE_C_COMPILER_ID}-${compiler_ver}/${CMAKE_C_COMPILER_FRONTEND_VARIANT}")
else()
    set(info "${info} compiler=${CMAKE_C_COMPILER_ID}-${compiler_ver}")
endif()
if (CMAKE_C_PLATFORM_ID)
    set(info "${info} runtime=${CMAKE_C_PLATFORM_ID}")
endif()
set(info "${info} | X86=${X86} X64=${X64} ARM=${ARM} ARM64=${ARM64} | Config=${CMAKE_BUILD_TYPE}")
string(REGEX REPLACE "." "-" delim ${info})
message(STATUS  "${delim}")
message(STATUS  "${info}")
message(STATUS  "${delim}")
unset(info)
unset(delim)

if ("Windows" STREQUAL CMAKE_SYSTEM_NAME)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
    add_compile_definitions(_SCL_SECURE_NO_WARNINGS)
    add_compile_definitions(_SILENCE_CXX20_CISO646_REMOVED_WARNING)
    add_compile_definitions(NOMINMAX)
    add_compile_definitions(WIN32_LEAN_AND_MEAN)
endif()
if ("MSVC" STREQUAL CMAKE_C_COMPILER_ID OR
    "MSVC" STREQUAL CMAKE_C_COMPILER_FRONTEND_VARIANT)
    add_compile_options(-Zc:__cplusplus)
    add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:/W3>)
    add_compile_options($<$<AND:$<CONFIG:RELEASE>,$<COMPILE_LANGUAGE:C,CXX>>:/Gy>)
    add_link_options($<$<CONFIG:RELEASE>:/OPT:REF>)  # eleminate unreferenced functions
    add_link_options($<$<CONFIG:RELEASE>:/OPT:ICF>)  # identical block folding
    # enable stack trace in release, generate symbol info
    string(REGEX REPLACE "/Zi" "" CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
    add_compile_options($<$<AND:$<CONFIG:RELEASE>,$<COMPILE_LANGUAGE:C,CXX>>:/Zi>)
    add_compile_options($<$<AND:$<CONFIG:RelWithDebInfo>,$<COMPILE_LANGUAGE:C,CXX>>:/ZI>)
    add_link_options($<$<CONFIG:RELEASE>:/DEBUG:fastlink>) # keep symbol info
    #if (X86)
    #    add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:/arch:AVX2>)
    #endif()
endif()
if ("GNU" STREQUAL CMAKE_C_COMPILER_ID OR
    "GNU" STREQUAL CMAKE_C_COMPILER_FRONTEND_VARIANT)
    add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-Wall>)
    add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-Wno-comment>) 
    #if (X86)
    #    add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-mavx2>)
    #endif()
    add_compile_definitions(__STDC_WANT_LIB_EXT1__=1 _GNU_SOURCE)
    add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-fno-omit-frame-pointer>)
    # add_link_options($<$<CONFIG:RELEASE>:-s>)     # strip RELEASE executables
endif()
if ("MinGW" STREQUAL CMAKE_C_PLATFORM_ID)         # https://sourceforge.net/p/mingw-w64/mailman/message/29128250/
    add_compile_definitions(__USE_MINGW_ANSI_STDIO)
endif()
if ("Clang"   STREQUAL CMAKE_C_COMPILER_ID AND    # Here the 'toolchain.cmake' file from the Android-NDK bundle is in use. CMake pass both
    "Android" STREQUAL CMAKE_SYSTEM_NAME)         # CFLAGS and ASMFLAGS to asm-compiler and this makes Clang complain for unknown flags.
    set(CMAKE_ASM_FLAGS "-Wno-unused-command-line-argument ${CMAKE_ASM_FLAGS}")
endif()
if ("Intel" STREQUAL CMAKE_C_COMPILER_ID)         # ICC has different options format for Windows and Linux build.
    if("Windows" STREQUAL CMAKE_HOST_SYSTEM_NAME)
        add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:/Qrestrict>)
        add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:/Qdiag-disable:167>) # "TYPE (*)[N]" is incompatible with parameter of type "const TYPE (*)[N]"
    else()
        add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-restrict>)
        add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-diag-disable=167>)
    endif()
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if (Darwin STREQUAL CMAKE_SYSTEM_NAME)
    set(CMAKE_CXX_VISIBILITY_PRESET hidden) 
endif()
