#Custom CMake configuration for Android 7 (Nougat) Core
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
    -DSNET_EVENT_LOG_TAG=1397638484
)

set(libcutils_options -Wall -Wextra)
set(liglog_options -fvisibility=hidden)

# Custom macros
# ============================================================

# copy files to CMAKE_RUNTIME_OUTPUT_DIRECTORY if defined
#               else to CMAKE_CURRENT_BINARY_DIRECTORY
function(copy_custom_target _target)
    set(out ${CMAKE_CURRENT_BINARY_DIR})
    if(IS_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
        set(out ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
    endif()

    foreach(file ${ARGN})
        get_filename_component(filename ${file} NAME_WE)
        list(APPEND out_files ${out}/${filename})
        add_custom_command(OUTPUT ${out}/${filename}
            COMMAND ${CMAKE_COMMAND} -E echo "Copying file ${filename} to ${out}"
            COMMAND ${CMAKE_COMMAND} -E copy ${file} ${out}
        )
    endforeach()

    add_custom_target(${_target} ALL DEPENDS ${out_files})
endfunction()

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
    ${CORE_SOURCE_DIR}/libcutils/config_utils.c
    ${CORE_SOURCE_DIR}/libcutils/fs_config.c
    ${CORE_SOURCE_DIR}/libcutils/canned_fs_config.c
    ${CORE_SOURCE_DIR}/libcutils/hashmap.c
    ${CORE_SOURCE_DIR}/libcutils/iosched_policy.c
    ${CORE_SOURCE_DIR}/libcutils/load_file.c
    ${CORE_SOURCE_DIR}/libcutils/native_handle.c
    ${CORE_SOURCE_DIR}/libcutils/open_memstream.c
    ${CORE_SOURCE_DIR}/libcutils/process_name.c
    ${CORE_SOURCE_DIR}/libcutils/record_stream.c
    ${CORE_SOURCE_DIR}/libcutils/sched_policy.c
    ${CORE_SOURCE_DIR}/libcutils/strlcpy.c
    ${CORE_SOURCE_DIR}/libcutils/threads.c
)

# liblog sources
set(LIBLOG_SRCS
    ${CORE_SOURCE_DIR}/liblog/log_event_list.c
    ${CORE_SOURCE_DIR}/liblog/log_event_write.c
    ${CORE_SOURCE_DIR}/liblog/logger_write.c
    ${CORE_SOURCE_DIR}/liblog/config_write.c
    ${CORE_SOURCE_DIR}/liblog/logger_name.c
    ${CORE_SOURCE_DIR}/liblog/logger_lock.c
    ${CORE_SOURCE_DIR}/liblog/fake_log_device.c
    ${CORE_SOURCE_DIR}/liblog/fake_writer.c
    ${CORE_SOURCE_DIR}/liblog/event_tag_map.c
)

set(APPEND2SIMG_SRCS ${CORE_SOURCE_DIR}/libsparse/append2simg.c)
set(IMG2SIMG_SRCS ${CORE_SOURCE_DIR}/libsparse/img2simg.c)
set(SIMG2IMG_SRCS ${CORE_SOURCE_DIR}/libsparse/simg2img.c)
set(SIMG2SIMG_SRCS ${CORE_SOURCE_DIR}/libsparse/simg2simg.c)
set(MKBOOTFS_SRCS ${CORE_SOURCE_DIR}/cpio/mkbootfs.c)
set(MKBOOTIMG_SRCS ${CORE_SOURCE_DIR}/mkbootimg/mkbootimg)
set(UNPACKBOOTIMG_SRCS ${CORE_SOURCE_DIR}/mkbootimg/unpackbootimg)



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
target_compile_options(libcutils PRIVATE ${libcutils_options})
set_target_properties(libcutils PROPERTIES OUTPUT_NAME cutils)

# liblog
add_library(liblog STATIC ${LIBLOG_SRCS})
target_include_directories(liblog PRIVATE ${core_include})
target_compile_definitions(liblog PRIVATE ${liblog_definitions})
target_compile_options(liblog PRIVATE ${liblog_options})
set_target_properties(liblog PROPERTIES OUTPUT_NAME log)

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
# pthread linking required
target_link_libraries(mkbootfs libcutils liblog pthread)

# mkbootimg
copy_custom_target(mkbootimg ${MKBOOTIMG_SRCS})

# unpackbootimg
if(EXISTS ${UNPACKBOOTIMG_SRCS})
    copy_custom_target(unpackbootimg ${UNPACKBOOTIMG_SRCS})
else()
    add_custom_target(unpackbootimg)
endif()