cmake_minimum_required(VERSION 3.5)

project(EDFlib VERSION 1.22 LANGUAGES C)

option(BUILD_SHARED_LIBS "Build EDFlib as a shared library." OFF)
option(BUILD_TOOLS "Build EDFlib tools." OFF)

include(CTest)
include(GNUInstallDirs)

set(sources edflib.h edflib.c)

if(WIN32 AND BUILD_SHARED_LIBS)
    list(APPEND sources exports.def)
endif()

add_library(EDFlib ${sources})

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
    install(FILES $<TARGET_PDB_FILE:EDFlib>
        DESTINATION "${CMAKE_INSTALL_BINDIR}" OPTIONAL
    )
endif()

install(EXPORT EDFlibTargets
    FILE EDFlibConfig.cmake
    DESTINATION "share/EDFlib"
)

if(BUILD_TOOLS)
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
    target_link_libraries(unittest PRIVATE EDFlib)

    if(MSVC AND NOT (MSVC_VERSION LESS 1900))
        target_compile_options(unittest PRIVATE /source-charset:.1252) # Or ISO-8859-1
        target_compile_options(unittest PRIVATE /execution-charset:.1252)
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
