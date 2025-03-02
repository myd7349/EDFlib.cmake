cmake_minimum_required(VERSION 3.15...3.31)

project(EDFlib VERSION 1.27 LANGUAGES C)

option(BUILD_SHARED_LIBS "Build EDFlib as a shared library." OFF)
option(EDF_BUILD_TOOLS "Build EDFlib tools." OFF)
option(EDF_HIDDEN_VISIBILITY "Use hidden visibility by default." OFF)
option(EDF_MSVC_STATIC_RUNTIME "Use MSVC static-linked runtime library." OFF)

include(CheckCCompilerFlag)
include(CTest)
include(GNUInstallDirs)

if(EDF_MSVC_STATIC_RUNTIME)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

set(sources edflib.h edflib.c)
add_library(EDFlib ${sources})

if(BUILD_SHARED_LIBS)
    target_compile_definitions(EDFlib
        PUBLIC
            EDFLIB_SO_DLL
        PRIVATE
            $<BUILD_INTERFACE:EDFLIB_BUILD>
    )

    if(EDF_HIDDEN_VISIBILITY)
        check_c_compiler_flag(-fvisibility=hidden HAVE_HIDDEN_VISIBILITY)

        if(HAVE_HIDDEN_VISIBILITY)
            set_target_properties(EDFlib PROPERTIES C_VISIBILITY_PRESET hidden)
        endif()
    endif()

    if(MSVC)
        target_compile_options(EDFlib PRIVATE $<$<CONFIG:Release>:/Zi>)

        target_link_options(EDFlib
            PRIVATE
                "$<$<CONFIG:Release>:/DEBUG;/OPT:REF;/OPT:ICF>"
        )
    endif()
endif()

target_compile_definitions(EDFlib
    PRIVATE
        $<$<C_COMPILER_ID:MSVC>:_CRT_SECURE_NO_WARNINGS>
)

if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    target_compile_definitions(EDFlib PRIVATE _LARGEFILE64_SOURCE _LARGEFILE_SOURCE)
endif()

set_target_properties(EDFlib PROPERTIES PUBLIC_HEADER edflib.h)

install(TARGETS EDFlib
    EXPORT EDFlibTargets
    PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

if(MSVC AND BUILD_SHARED_LIBS)
    install(FILES $<TARGET_PDB_FILE:${PROJECT_NAME}>
        DESTINATION "${CMAKE_INSTALL_BINDIR}" OPTIONAL
    )
endif()

install(EXPORT EDFlibTargets
    FILE EDFlibConfig.cmake
    DESTINATION "share/EDFlib"
)

if(EDF_BUILD_TOOLS)
    include(CheckSymbolExists)

    # https://stackoverflow.com/questions/32816646/can-cmake-detect-if-i-need-to-link-to-libm-when-using-pow-in-c
    if(NOT POW_FUNCTION_EXISTS AND NOT NEED_LINKING_AGAINST_LIBM)
        check_symbol_exists(pow "math.h" POW_FUNCTION_EXISTS)
        if(NOT POW_FUNCTION_EXISTS)
            unset(POW_FUNCTION_EXISTS CACHE)
            list(APPEND CMAKE_REQUIRED_LIBRARIES m)
            check_symbol_exists(pow "math.h" POW_FUNCTION_EXISTS)
            if(POW_FUNCTION_EXISTS)
                set(NEED_LINKING_AGAINST_LIBM True CACHE BOOL "" FORCE)
            else()
                message(FATAL_ERROR "Failed making the pow() function available")
            endif()
        endif()
    endif()

    add_executable(sine_generator sine_generator.c)
    target_link_libraries(sine_generator PRIVATE EDFlib)

    add_executable(sweep_generator sweep_generator.c)
    target_compile_definitions(sweep_generator
        PRIVATE
            $<$<C_COMPILER_ID:MSVC>:_CRT_SECURE_NO_WARNINGS>
    )
    target_link_libraries(sweep_generator PRIVATE EDFlib)

    add_executable(test_edflib test_edflib.c)
    target_link_libraries(test_edflib PRIVATE EDFlib)

    add_executable(test_generator test_generator.c)
    target_link_libraries(test_generator PRIVATE EDFlib)

    if(NEED_LINKING_AGAINST_LIBM)
        target_link_libraries(sine_generator PRIVATE m)
        target_link_libraries(sweep_generator PRIVATE m)
        target_link_libraries(test_generator PRIVATE m)
    endif()

    install(TARGETS sine_generator sweep_generator test_edflib test_generator
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    )
endif()

if(BUILD_TESTING)
    add_executable(unittest unittest/unittest.c)

    target_compile_definitions(unittest
        PRIVATE
            $<$<C_COMPILER_ID:MSVC>:_CRT_SECURE_NO_WARNINGS>
    )

    target_link_libraries(unittest PRIVATE EDFlib)

    if(MSVC AND NOT (MSVC_VERSION LESS 1900))
        target_compile_options(unittest PRIVATE /source-charset:.1252) # Or ISO-8859-1
        target_compile_options(unittest PRIVATE /execution-charset:.1252)
    endif()

    check_c_compiler_flag("-finput-charset=ISO-8859-1 -fexec-charset=ISO-8859-1" SUPPORTS_INPUT_CHARSET_FLAG)
    if(SUPPORTS_INPUT_CHARSET_FLAG)
        target_compile_options(unittest PRIVATE -finput-charset=ISO-8859-1 -fexec-charset=ISO-8859-1)
    endif()

    add_test(unittest unittest)
endif()


# References:
# [C++ Visual Studio character encoding issues](https://stackoverflow.com/questions/1857668/c-visual-studio-character-encoding-issues)
# https://docs.microsoft.com/en-us/cpp/build/reference/unicode-support-in-the-compiler-and-linker?view=msvc-170
# [In CMake, how can I test if the compiler is Clang?](https://stackoverflow.com/questions/10046114/in-cmake-how-can-i-test-if-the-compiler-is-clang)
# [What is the difference between _LARGEFILE_SOURCE and _FILE_OFFSET_BITS=64?](https://stackoverflow.com/questions/14184031/what-is-the-difference-between-largefile-source-and-file-offset-bits-64)
# [Specification of source charset encoding in MSVC++, like gcc "-finput-charset=CharSet"](https://stackoverflow.com/questions/1660712/specification-of-source-charset-encoding-in-msvc-like-gcc-finput-charset-ch)
# https://docs.microsoft.com/en-us/cpp/build/reference/source-charset-set-source-character-set?view=msvc-170
# https://docs.microsoft.com/en-us/cpp/build/reference/execution-charset-set-execution-character-set?view=msvc-170
# [IANA Character Sets](https://www.iana.org/assignments/character-sets/character-sets.xhtml)
# https://docs.microsoft.com/en-us/windows/win32/Intl/code-page-identifiers
# [How to set standard encoding in Visual Studio](https://stackoverflow.com/questions/696627/how-to-set-standard-encoding-in-visual-studio)
# [C++ Visual Studio character encoding issues](https://stackoverflow.com/questions/1857668/c-visual-studio-character-encoding-issues)
# [how to generate pdb files for Release build with cmake flags?](https://stackoverflow.com/questions/28178978/how-to-generate-pdb-files-for-release-build-with-cmake-flags)
# [Release generating .pdb files, why?](https://stackoverflow.com/questions/5457095/release-generating-pdb-files-why)
# [How to get CMake to install PDB files for targets](https://stackoverflow.com/questions/40860435/how-to-get-cmake-to-install-pdb-files-for-targets)
# [What are CMAKE_BUILD_TYPE: Debug, Release, RelWithDebInfo and MinSizeRel?](https://stackoverflow.com/questions/48754619/what-are-cmake-build-type-debug-release-relwithdebinfo-and-minsizerel)
# [CMake build mode RelWithDebInfo](https://stackoverflow.com/questions/1239845/cmake-build-mode-relwithdebinfo)
# [Why not always build a release with debug info?](https://stackoverflow.com/questions/47703642/why-not-always-build-a-release-with-debug-info)
# [What is the proper way to build for macOS-x86_64 using cmake on Apple M1 (arm)?](https://stackoverflow.com/questions/69803659/what-is-the-proper-way-to-build-for-macos-x86-64-using-cmake-on-apple-m1-arm)
# https://github.com/skywind3000/PyStand/pull/39
# https://github.com/f3d-app/f3d/blob/master/.github/workflows/ci.yml
# https://github.com/Slackadays/Clipboard/blob/main/.github/workflows/build-clipboard.yml
# > -DCMAKE_GENERATOR_PLATFORM=ARM64
# https://github.com/nihui/opencv-mobile/blob/master/.github/workflows/release.yml
# > cmake ${{ env.COMMON_CMAKE_OPTIONS }} -DARCHS="arm64"
# https://github.com/nihui/opencv-mobile/blob/master/toolchains/macos-arm64.toolchain.cmake
# > set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "Build architecture")
# https://github.com/gongminmin/KlayGE/blob/develop/Build/CMake/Modules/iOS.cmake
# [How to determine which architectures are available (Apple M1)?](https://discourse.cmake.org/t/how-to-determine-which-architectures-are-available-apple-m1/2401)
# > SET(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "Build architectures for Mac OS X" FORCE)
# [How to set CMAKE_OSX_ARCHITECTURES in CMakeLists depending on debug or release configuration?](https://stackoverflow.com/questions/75013303/how-to-set-cmake-osx-architectures-in-cmakelists-depending-on-debug-or-release-c)
# [How to pass the CMAKE_OSX_ARCHITECTURES with multiple values in the ExternalProject_Add's CMAKE_ARGS](https://stackoverflow.com/questions/75860014/how-to-pass-the-cmake-osx-architectures-with-multiple-values-in-the-externalproj)
# [GCC 4.7 Source Character Encoding and Execution Character Encoding For String Literals?](https://stackoverflow.com/questions/12216946/gcc-4-7-source-character-encoding-and-execution-character-encoding-for-string-li)
# [Possible to force CMake/MSVC to use UTF-8 encoding for source files without a BOM? C4819](https://stackoverflow.com/questions/47690822/possible-to-force-cmake-msvc-to-use-utf-8-encoding-for-source-files-without-a-bo)
# [Xcode 4.6 (4H127), clang warns 'illegal character encoding in string literal' for ISO-8859-1 encoded o-umlaut (0xF6)](https://stackoverflow.com/questions/14717356/xcode-4-6-4h127-clang-warns-illegal-character-encoding-in-string-literal-fo)
# [ RFC: Enabling fexec-charset support to LLVM and clang (Reposting)](https://discourse.llvm.org/t/rfc-enabling-fexec-charset-support-to-llvm-and-clang-reposting/71512)
# https://clang.llvm.org/docs/ClangCommandLineReference.html
# [Cross Compiling With CMake](https://cmake.org/cmake/help/book/mastering-cmake/chapter/Cross%20Compiling%20With%20CMake.html)
# [How to cross compile CMake for ARM with CMake](https://stackoverflow.com/questions/12844772/how-to-cross-compile-cmake-for-arm-with-cmake)
# https://github.com/jobroe/cmake-arm-embedded
# [How to cross compile for ARM?](https://askubuntu.com/questions/250696/how-to-cross-compile-for-arm)
# https://github.com/nihui/opencv-mobile/tree/master/toolchains
# [Difference between arm-eabi arm-gnueabi and gnueabi-hf compilers [closed]](https://stackoverflow.com/questions/26692065/difference-between-arm-eabi-arm-gnueabi-and-gnueabi-hf-compilers)
# [Difference between arm-none-eabi and arm-linux-gnueabi?](https://stackoverflow.com/questions/38956680/difference-between-arm-none-eabi-and-arm-linux-gnueabi)
# [What is the difference between arm-linux-gcc and arm-none-linux-gnueabi](https://stackoverflow.com/questions/13797693/what-is-the-difference-between-arm-linux-gcc-and-arm-none-linux-gnueabi)
# https://packages.ubuntu.com/
# https://github.com/nihui/opencv-mobile/blob/master/.github/workflows/release.yml
# https://github.com/Slackadays/Clipboard/blob/main/.github/workflows/build-clipboard.yml
# [How to detect if 64 bit MSVC with cmake?](https://stackoverflow.com/questions/39258250/how-to-detect-if-64-bit-msvc-with-cmake)
# [how to generate pdb files for Release build with cmake flags?](https://stackoverflow.com/questions/28178978/how-to-generate-pdb-files-for-release-build-with-cmake-flags)
# https://github.com/microsoft/vcpkg/blob/ee2d2a100103e0f3613c60655dcf15be7d5157b8/scripts/toolchains/windows.cmake#L94
# [How to use the __attribute__((visibility("default")))?](https://stackoverflow.com/questions/52719364/how-to-use-the-attribute-visibilitydefault)
# https://gitlab.com/Teuniz/EDFlib/-/issues/20
# https://github.com/curl/curl/blob/97abcbd6ff28a6ce1940992a6db832d6bd2f1ac3/include/curl/curl.h#L134
# https://github.com/nanomsg/nng/blob/dba356ddc23f59e158368e8f1af4f714bca9c111/CMakeLists.txt#L204
# https://github.com/nanomsg/nng/blob/dba356ddc23f59e158368e8f1af4f714bca9c111/src/CMakeLists.txt#L32
# [Setting the MSVC runtime in CMake](https://stackoverflow.com/questions/10113017/setting-the-msvc-runtime-in-cmake)
# https://github.com/raylib-cs/raylib-cs/blob/91cfbeaf5ef413ceed5a8bb606cfedbc8bfef47e/Raylib-cs.Native/Raylib-cs.Native.csproj#L58
# > <CMakeArgs Include="-D CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded" />
