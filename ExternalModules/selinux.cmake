#Custom CMake configuration for Android 8 (Oreo) Extras
cmake_minimum_required(VERSION 3.8)
project("Selinux" C CXX)

# External libraries
# ============================================================

# Compile Options
# ============================================================

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -std=c++11")

add_compile_options(-Werror)

set(libselinux_include ${SELINUX_SOURCE_DIR}/libselinux/include)
set(pcre_include ${PCRE_SOURCE_DIR}/include)

set(libselinux_definitions
    -DBUILD_HOST
    -DUSE_PCRE2
    -DNO_PERSISTENTLY_STORED_PATTERNS
    -DDISABLE_SETRANS
    -DDISABLE_BOOL
    -D_GNU_SOURCE
    -DNO_MEDIA_BACKEND
    -DNO_X_BACKEND
    -DNO_DB_BACKEND
)

# Sources
# ============================================================

# libselinux sources
set(LIBSELINUX_SRCS
    ${SELINUX_SOURCE_DIR}/libselinux/src/booleans.c
    ${SELINUX_SOURCE_DIR}/libselinux/src/callbacks.c
    ${SELINUX_SOURCE_DIR}/libselinux/src/freecon.c
    ${SELINUX_SOURCE_DIR}/libselinux/src/label_backends_android.c
    ${SELINUX_SOURCE_DIR}/libselinux/src/label.c
    ${SELINUX_SOURCE_DIR}/libselinux/src/label_support.c
    ${SELINUX_SOURCE_DIR}/libselinux/src/matchpathcon.c
    ${SELINUX_SOURCE_DIR}/libselinux/src/setrans_client.c
    ${SELINUX_SOURCE_DIR}/libselinux/src/sha1.c
    ${SELINUX_SOURCE_DIR}/libselinux/src/label_file.c
    ${SELINUX_SOURCE_DIR}/libselinux/src/regex.c
)

# Build libraries
# ============================================================

# libselinux
add_library(libselinux STATIC ${LIBSELINUX_SRCS})
target_include_directories(libselinux PRIVATE ${libselinux_include} ${pcre_include})
target_compile_definitions(libselinux PRIVATE ${libselinux_definitions})
set_target_properties(libselinux PROPERTIES OUTPUT_NAME selinux)
