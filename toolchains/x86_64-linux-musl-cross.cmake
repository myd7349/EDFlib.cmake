set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(BASE_DIR "${CMAKE_CURRENT_LIST_DIR}/../x86_64-linux-musl-cross/bin")

SET(CMAKE_C_COMPILER "${BASE_DIR}/x86_64-linux-musl-gcc")
SET(CMAKE_CXX_COMPILER "${BASE_DIR}/x86_64-linux-musl-g++")
SET(CMAKE_AR "${BASE_DIR}/x86_64-linux-musl-ar")
SET(CMAKE_STRIP "${BASE_DIR}/x86_64-linux-musl-strip")
SET(CMAKE_RANLIB "${BASE_DIR}/x86_64-linux-musl-ranlib")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# References:
# https://github.com/kleisauke/libvips-packaging/blob/main/platforms/linux-musl-arm64/Toolchain.cmake
# https://github.com/lovell/aarch64-linux-musl-crosstools
# https://musl.cc/
# https://github.com/richfelker/musl-cross-make
# https://github.com/rsenn/cmake-toolchains
# https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html
