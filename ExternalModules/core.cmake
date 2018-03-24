# Custom CMake configuration for Android 6 (Marshmallow) Core
cmake_minimum_required(VERSION 3.8)
project("Core" C)

# External libraries
# ============================================================

set(libz "${LIBZ_BINARY_DIR}/libz.a")

# Compile options
# ============================================================

add_compile_options(-Werror)

set(libsparse_include ${CORE_SOURCE_DIR}/libsparse/include)
set(core_include ${CORE_SOURCE_DIR}/include)

set(liblog_definitions 
    -DFAKE_LOG_DEVICE=1
    -DLIBLOG_LOG_TAG=1005
)

set(libmincrypt_options -Wall)

# Sources
# ============================================================

# libsparse sources
set(LIBSPARSE_SRCS
    ${CORE_SOURCE_DIR}/libsparse/backed_block.c
    ${CORE_SOURCE_DIR}/libsparse/output_file.c
    ${CORE_SOURCE_DIR}/libsparse/sparse.c
    ${CORE_SOURCE_DIR}/libsparse/sparse_crc32.c
    ${CORE_SOURCE_DIR}/libsparse/sparse_err.c
    ${CORE_SOURCE_DIR}/libsparse/sparse_read.c
)

# libcutil sources
set(LIBCUTILS_SRCS
    ${CORE_SOURCE_DIR}/libcutils/hashmap.c
    ${CORE_SOURCE_DIR}/libcutils/native_handle.c
    ${CORE_SOURCE_DIR}/libcutils/config_utils.c
    ${CORE_SOURCE_DIR}/libcutils/load_file.c
    ${CORE_SOURCE_DIR}/libcutils/strlcpy.c
    ${CORE_SOURCE_DIR}/libcutils/open_memstream.c
    ${CORE_SOURCE_DIR}/libcutils/record_stream.c
    ${CORE_SOURCE_DIR}/libcutils/process_name.c
    ${CORE_SOURCE_DIR}/libcutils/threads.c
    ${CORE_SOURCE_DIR}/libcutils/sched_policy.c
    ${CORE_SOURCE_DIR}/libcutils/iosched_policy.c
    ${CORE_SOURCE_DIR}/libcutils/str_parms.c
    ${CORE_SOURCE_DIR}/libcutils/fs_config.c
)

# liblog sources
set(LIBLOG_SRCS
    ${CORE_SOURCE_DIR}/liblog/logd_write.c
    ${CORE_SOURCE_DIR}/liblog/log_event_write.c
    ${CORE_SOURCE_DIR}/liblog/uio.c
    ${CORE_SOURCE_DIR}/liblog/fake_log_device.c
)

# libmincrypt sources
set(LIBMINCRYPT_SRCS
    ${CORE_SOURCE_DIR}/libmincrypt/dsa_sig.c
    ${CORE_SOURCE_DIR}/libmincrypt/p256.c
    ${CORE_SOURCE_DIR}/libmincrypt/p256_ec.c
    ${CORE_SOURCE_DIR}/libmincrypt/p256_ecdsa.c
    ${CORE_SOURCE_DIR}/libmincrypt/rsa.c
    ${CORE_SOURCE_DIR}/libmincrypt/sha.c
    ${CORE_SOURCE_DIR}/libmincrypt/sha256.c
)

set(APPEND2SIMG_SRCS ${CORE_SOURCE_DIR}/libsparse/append2simg.c)
set(IMG2SIMG_SRCS ${CORE_SOURCE_DIR}/libsparse/img2simg.c)
set(SIMG2IMG_SRCS ${CORE_SOURCE_DIR}/libsparse/simg2img.c)
set(SIMG2SIMG_SRCS ${CORE_SOURCE_DIR}/libsparse/simg2simg.c)
set(MKBOOTFS_SRCS ${CORE_SOURCE_DIR}/cpio/mkbootfs.c)
set(MKBOOTIMG_SRCS ${CORE_SOURCE_DIR}/mkbootimg/mkbootimg.c)
set(UNPACKBOOTIMG_SRCS ${CORE_SOURCE_DIR}/mkbootimg/unpackbootimg.c)


# Build libraries
# ============================================================

# libsparse
add_library(libsparse STATIC ${LIBSPARSE_SRCS})
target_include_directories(libsparse PRIVATE ${libsparse_include})
set_target_properties(libsparse PROPERTIES OUTPUT_NAME sparse)
if(NOT EXISTS ${libz})
    message(WARNING "libz is missing.
    LIBZ_BINARY_DIR: ${LIBZ_BINARY_DIR} does not have libz.a")
endif()
target_link_libraries(libsparse ${libz})

# libcutils
add_library(libcutils STATIC ${LIBCUTILS_SRCS})
target_include_directories(libcutils PRIVATE ${core_include})
set_target_properties(libcutils PROPERTIES OUTPUT_NAME cutils)

# liblog
add_library(liblog STATIC ${LIBLOG_SRCS})
target_include_directories(liblog PRIVATE ${core_include})
target_compile_definitions(liblog PRIVATE ${liblog_definitions})
set_target_properties(liblog PROPERTIES OUTPUT_NAME log)

# libmincrypt
add_library(libmincrypt STATIC ${LIBMINCRYPT_SRCS})
target_include_directories(libmincrypt PRIVATE ${core_include})
target_compile_options(libmincrypt PRIVATE ${libmincrypt_options})
set_target_properties(libmincrypt PROPERTIES OUTPUT_NAME mincrypt)

# Build executables
# ============================================================

# append2simg
add_executable(append2simg ${APPEND2SIMG_SRCS})
target_include_directories(append2simg PRIVATE ${libsparse_include})
target_link_libraries(append2simg libsparse)

# img2simg
add_executable(img2simg ${IMG2SIMG_SRCS})
target_include_directories(img2simg PRIVATE ${libsparse_include})
target_link_libraries(img2simg libsparse)

# simg2img
add_executable(simg2img ${SIMG2IMG_SRCS})
target_include_directories(simg2img PRIVATE ${libsparse_include})
target_link_libraries(simg2img libsparse)

# simg2simg
add_executable(simg2simg ${SIMG2SIMG_SRCS})
target_include_directories(simg2simg PRIVATE ${libsparse_include})
target_link_libraries(simg2simg libsparse)

# mkbootfs
add_executable(mkbootfs ${MKBOOTFS_SRCS})
target_include_directories(mkbootfs PRIVATE ${core_include})
target_link_libraries(mkbootfs libcutils liblog)

# mkbootimg
add_executable(mkbootimg ${MKBOOTIMG_SRCS})
target_include_directories(mkbootimg PRIVATE ${core_include})
target_link_libraries(mkbootimg libmincrypt)

# unpackbootimg
if(EXISTS ${UNPACKBOOTIMG_SRCS})
    add_executable(unpackbootimg ${UNPACKBOOTIMG_SRCS})
    target_include_directories(unpackbootimg PRIVATE ${core_include})
else()
    add_custom_target(unpackbootimg)
endif()
