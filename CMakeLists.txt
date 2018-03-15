cmake_minimum_required(VERSION 3.8)
project("Android Image Repack Tools 2" C)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules")

include(Default)
include(Current)

# CMAKE Configuration
# ============================================================

set(CMAKE_BUILD_TYPE Debug Release CACHE STRING "" FORCE)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)

# Android Modules
# ============================================================

include(ExternalProject)
find_package(Git REQUIRED)
include(Macros)

set(COMMON_CMAKE_ARGS 
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    -DANDROID_VERSION:STRING=${ANDROID_VERSION}
)

# Append android modules's source directory and binary directory
foreach(module ${ANDROID_SUBMODULES})
    list(APPEND COMMON_CMAKE_ARGS
        -D${module}_SOURCE_DIR:PATH=${${module}_SOURCE_DIR}
        -D${module}_BINARY_DIR:PATH=${${module}_BINARY_DIR}
    )
endforeach()

# LIBZ
m_ExternalProject_Add(LIBZ
    CONFIGURE_COMMAND ${CMAKE_COMMAND} ${LIBZ_SOURCE_DIR}/src
    BUILD_COMMAND ""
    SOURCE_SUBDIR src
    STEP_TARGETS configure
)

# PCRE
m_ExternalProject_Add(PCRE
    CONFIGURE_COMMAND ${CMAKE_COMMAND} ${PCRE_SOURCE_DIR}/dist
    BUILD_COMMAND ""
    STEP_TARGETS configure
)

# LIBSELINUX
m_ExternalProject_Add(LIBSELINUX
    PATCH_COMMAND ${CMAKE_COMMAND} -E echo "Adding custom cmake configuration"
    COMMAND ${CMAKE_COMMAND} -E copy ${EXTERNAL_MODULES_DIR}/libselinux.cmake ${LIBSELINUX_DIR}/CMakeLists.txt
    CMAKE_CACHE_ARGS ${COMMON_CMAKE_ARGS}
    BUILD_COMMAND ""
    SOURCE_SUBDIR ${RELATIVE_LIBSELINUX_SOURCE}
    STEP_TARGETS configure
)
ExternalProject_Add_StepDependencies(LIBSELINUX patch "${EXTERNAL_MODULES_DIR}/libselinux.cmake")

# CORE
m_ExternalProject_Add(CORE
    PATCH_COMMAND ${CMAKE_COMMAND} -E echo "Adding custom cmake configuration"
    COMMAND ${CMAKE_COMMAND} -E copy ${EXTERNAL_MODULES_DIR}/core.cmake ${CORE_DIR}/CMakeLists.txt
    CMAKE_CACHE_ARGS ${COMMON_CMAKE_ARGS}
    BUILD_COMMAND ""
    SOURCE_SUBDIR ${RELATIVE_CORE_SOURCE}
    STEP_TARGETS configure
)
ExternalProject_Add_StepDependencies(CORE patch "${EXTERNAL_MODULES_DIR}/core.cmake")
ExternalProject_Add_StepDependencies(CORE configure libz)

# EXTRAS
m_ExternalProject_Add(EXTRAS
    PATCH_COMMAND ${CMAKE_COMMAND} -E echo "Adding custom cmake configuration"
    COMMAND ${CMAKE_COMMAND} -E copy ${EXTERNAL_MODULES_DIR}/extras.cmake ${EXTRAS_DIR}/CMakeLists.txt
    CMAKE_CACHE_ARGS ${COMMON_CMAKE_ARGS}
    BUILD_COMMAND ""
    SOURCE_SUBDIR ${RELATIVE_EXTRAS_SOURCE}
    STEP_TARGETS configure
)
ExternalProject_Add_StepDependencies(EXTRAS patch "${EXTERNAL_MODULES_DIR}/extras.cmake")
ExternalProject_Add_StepDependencies(EXTRAS configure libz libpcre libselinux libsparse libcutils liblog)

unset(EXTERNAL_MODULES_DIR)

# Building binaries
# ============================================================

# Build libz
m_build_target(libz zlibstatic LIBZ)
add_dependencies(libz LIBZ-configure)

# Build libpcre
m_build_target(libpcre pcre PCRE)
add_dependencies(libpcre PCRE-configure)

# Build libselinux
m_build_target(libselinux libselinux LIBSELINUX)
add_dependencies(libselinux LIBSELINUX-configure)

# Build libsparse
m_build_target(libsparse libsparse CORE)
add_dependencies(libsparse libz CORE-configure)

# Build libcutils
m_build_target(libcutils libcutils CORE)
add_dependencies(libcutils CORE-configure)

# Build liblog
m_build_target(liblog liblog CORE)
add_dependencies(liblog CORE-configure)

# Build libmincrypt
m_build_target(libmincrypt libmincrypt CORE)
add_dependencies(libmincrypt CORE-configure)

# Build append2simg
m_build_target(append2simg append2simg CORE)
add_dependencies(append2simg libsparse CORE-configure)

# Build img2simg
m_build_target(img2simg img2simg CORE)
add_dependencies(img2simg libsparse CORE-configure)

# Build simg2img
m_build_target(simg2img simg2img CORE)
add_dependencies(simg2img libsparse CORE-configure)

# Build simg2simg
m_build_target(simg2simg simg2simg CORE)
add_dependencies(simg2simg libsparse CORE-configure)

# mkbootfs
m_build_target(mkbootfs mkbootfs CORE)
add_dependencies(mkbootfs libcutils liblog CORE-configure)

# mkbootimg
m_build_target(mkbootimg mkbootimg CORE)
add_dependencies(mkbootimg libmincrypt CORE-configure)

# unpackbootimg
m_build_target(unpackbootimg unpackbootimg CORE)
add_dependencies(unpackbootimg CORE-configure)

# make_ext4fs
m_build_target(make_ext4fs make_ext4fs EXTRAS)
add_dependencies(make_ext4fs libz libpcre libselinux libsparse libcutils liblog EXTRAS-configure)

# Miscellaneous
# ============================================================

# Download, update and patch all external libraries
add_custom_target(external)

foreach(module ${ANDROID_SUBMODULES})
    ExternalProject_Add_StepTargets(${module} download update patch)
    add_dependencies(external ${module}-download ${module}-update ${module}-patch)
endforeach()


# cleans all project. Default clean doesn't clean external libraries.
add_custom_target(all-clean COMMAND ${CMAKE_COMMAND} --build . --target clean)

foreach(module ${ANDROID_SUBMODULES})
    m_ExternalProject_CleanStep(${module})
    add_dependencies(all-clean ${module}-clean)
endforeach()
