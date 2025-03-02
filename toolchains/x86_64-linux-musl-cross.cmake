set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(CMAKE_C_COMPILER x86_64-linux-musl-gcc)
set(CMAKE_CXX_COMPILER x86_64-linux-musl-g++)
set(CMAKE_AR x86_64-linux-musl-ar)
set(CMAKE_STRIP x86_64-linux-musl-strip)
set(CMAKE_RANLIB x86_64-linux-musl-ranlib)

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
# https://github.com/opencv/opencv/issues/7594
