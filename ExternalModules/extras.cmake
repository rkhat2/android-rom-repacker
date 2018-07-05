# Custom CMake configuration for Android Wear 5 Extras
cmake_minimum_required(VERSION 3.8)
project("Extras" C)

# External libraries
# ============================================================

# libpcre needs to be linked after libselinux
set(libselinux "${LIBSELINUX_BINARY_DIR}/libselinux.a")
set(libpcre "${PCRE_BINARY_DIR}/libpcre.a")

# libz needs to be linked after libsparse
set(libsparse "${CORE_BINARY_DIR}/libsparse.a")
set(libz "${LIBZ_BINARY_DIR}/libz.a")

# liblog needs to be linked after libcutils
set(libcutils "${CORE_BINARY_DIR}/libcutils.a")
set(liblog "${CORE_BINARY_DIR}/liblog.a")


# Compile Options
# ============================================================

add_compile_options(-Werror)

set(libselinux_include ${LIBSELINUX_SOURCE_DIR}/include)
set(libsparse_include ${CORE_SOURCE_DIR}/libsparse/include)
set(core_include ${CORE_SOURCE_DIR}/include)

set(make_ext4fs_definitions -DANDROID -DHOST)

# Sources
# ============================================================

# original make_ext4fs.c
set(MAKE_EXT4FS_ORIGINAL
    ${EXTRAS_SOURCE_DIR}/ext4_utils/make_ext4fs.c
)

# modified make_ext4fs.c
set(MAKE_EXT4FS_DEF
    ${CMAKE_SOURCE_DIR}/make_ext4fs_def.c
)
set_property(DIRECTORY ${CMAKE_SOURCE_DIR}
    PROPERTY INCLUDE_DIRECTORIES ${EXTRAS_SOURCE_DIR}/ext4_utils
)

# libext4 sources
set(LIBEXT4_SRCS
    ${EXTRAS_SOURCE_DIR}/ext4_utils/ext4fixup.c
    ${EXTRAS_SOURCE_DIR}/ext4_utils/ext4_utils.c
    ${EXTRAS_SOURCE_DIR}/ext4_utils/allocate.c
    ${EXTRAS_SOURCE_DIR}/ext4_utils/contents.c
    ${EXTRAS_SOURCE_DIR}/ext4_utils/extent.c
    ${EXTRAS_SOURCE_DIR}/ext4_utils/indirect.c
    ${EXTRAS_SOURCE_DIR}/ext4_utils/uuid.c 
    ${EXTRAS_SOURCE_DIR}/ext4_utils/sha1.c
    ${EXTRAS_SOURCE_DIR}/ext4_utils/wipe.c
    ${EXTRAS_SOURCE_DIR}/ext4_utils/crc16.c
    ${EXTRAS_SOURCE_DIR}/ext4_utils/ext4_sb.c
)

# make_ext4fs sources
set(MAKE_EXT4FS_SRCS
    ${EXTRAS_SOURCE_DIR}/ext4_utils/make_ext4fs_main.c
    ${EXTRAS_SOURCE_DIR}/ext4_utils/canned_fs_config.c
)

# Build executables
# ============================================================

add_executable(make_ext4fs ${MAKE_EXT4FS_SRCS} ${MAKE_EXT4FS_ORIGINAL} ${LIBEXT4_SRCS})
target_include_directories(make_ext4fs PRIVATE ${libselinux_include} ${libsparse_include} ${core_include})
target_compile_definitions(make_ext4fs PRIVATE ${make_ext4fs_definitions})

add_executable(make_ext4fs_def ${MAKE_EXT4FS_SRCS} ${MAKE_EXT4FS_DEF} ${LIBEXT4_SRCS})
target_include_directories(make_ext4fs_def PRIVATE ${libselinux_include} ${libsparse_include} ${core_include})
target_compile_definitions(make_ext4fs_def PRIVATE ${make_ext4fs_definitions})

if(NOT EXISTS ${libselinux})
    message(WARNING "libselinux is missing.
    LIBSELINUX_BINARY_DIR: ${LIBSELINUX_BINARY_DIR} does not have libselinux.a")
endif()
if(NOT EXISTS ${libpcre})
    message(WARNING "libpcre is missing.
    PCRE_BINARY_DIR: ${PCRE_BINARY_DIR} does not have libpcre2.a")
endif()
if(NOT EXISTS ${libsparse})
    message(WARNING "libsparse is missing.
    LIBSPARSE_BINARY_DIR: ${LIBSPARSE_BINARY_DIR} does not have libsparse.a")
endif()
if(NOT EXISTS ${libz})
    message(WARNING "Libz is missing.
    LIBZ_BINARY_DIR: ${LIBZ_BINARY_DIR} does not have libz.a")
endif()
if(NOT EXISTS ${libcutils})
    message(WARNING "libcutils is missing.
    LIBCUTILS_BINARY_DIR: ${LIBCUTILS_BINARY_DIR} does not have libcutils.a")
endif()
if(NOT EXISTS ${liblog})
    message(WARNING "liblog is missing.
    LIBLOG_BINARY_DIR: ${LIBLOG_BINARY_DIR} does not have liblog.a")
endif()

target_link_libraries(make_ext4fs
    ${libselinux}
    ${libpcre}
    ${libsparse}
    ${libz}
    ${libcutils}
    ${liblog}
)

target_link_libraries(make_ext4fs_def
    ${libselinux}
    ${libpcre}
    ${libsparse}
    ${libz}
    ${libcutils}
    ${liblog}
)
