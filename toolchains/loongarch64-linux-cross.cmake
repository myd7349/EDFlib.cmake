set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR loongarch64)

set(CMAKE_C_COMPILER loongarch64-unknown-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER loongarch64-unknown-linux-gnu-g++)
set(CMAKE_AR loongarch64-unknown-linux-gnu-ar)
set(CMAKE_STRIP loongarch64-unknown-linux-gnu-strip)
set(CMAKE_RANLIB loongarch64-unknown-linux-gnu-ranlib)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# References:
# https://github.com/simdjson/simdjson/blob/master/.github/workflows/loongarch64.yml
