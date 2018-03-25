cmake_minimum_required(VERSION 3.8)
project("Android Rom Repack" C)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules")

include(Default)
include(Current)

# CMAKE Configuration
# ============================================================

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)

# Android Modules
# ============================================================

include(ExternalProject)
find_package(Git REQUIRED)
include(Macros)

set(COMMON_CMAKE_ARGS 
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    -DANDROID_VERSION:STRING=${ANDROID_VERSION}
)

if(CMAKE_BUILD_TYPE)
    list(APPEND COMMON_CMAKE_ARGS
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    )
endif()

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
    CONFIGURE_COMMAND ${CMAKE_COMMAND} ${PCRE_SOURCE_DIR}/dist2
    BUILD_COMMAND ""
    STEP_TARGETS configure
)

# SELINUX
m_ExternalProject_Add(SELINUX
    PATCH_COMMAND ${CMAKE_COMMAND} -E echo "Adding custom cmake configuration"
    COMMAND ${CMAKE_COMMAND} -E copy ${EXTERNAL_MODULES_DIR}/selinux.cmake ${SELINUX_DIR}/CMakeLists.txt
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/src/sefcontext_decompile.c ${SELINUX_DIR}/sefcontext_decompile.c
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/src/label_file2.h ${SELINUX_DIR}/label_file2.h
    CMAKE_CACHE_ARGS ${COMMON_CMAKE_ARGS}
    BUILD_COMMAND ""
    SOURCE_SUBDIR ${RELATIVE_SELINUX_SOURCE}
    STEP_TARGETS configure
)
ExternalProject_Add_StepDependencies(SELINUX patch
    "${EXTERNAL_MODULES_DIR}/selinux.cmake"
    "${CMAKE_SOURCE_DIR}/src/sefcontext_decompile.c"
    "${CMAKE_SOURCE_DIR}/src/label_file2.h"
)
ExternalProject_Add_StepDependencies(SELINUX configure libpcre)

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
ExternalProject_Add_StepDependencies(EXTRAS configure libz libselinux libsparse libcutils liblog)

# Building binaries
# ============================================================

# Build libz
m_build_target(libz zlibstatic LIBZ)
add_dependencies(libz LIBZ-configure)

# Build libpcre
m_build_target(libpcre pcre2-8 PCRE)
add_dependencies(libpcre PCRE-configure)

# Build libselinux
m_build_target(libselinux libselinux SELINUX)
add_dependencies(libselinux SELINUX-configure)

# Build libsepol
m_build_target(libsepol libsepol SELINUX)
add_dependencies(libsepol SELINUX-configure)

# Build libbase
m_build_target(libbase libbase CORE)
add_dependencies(libbase CORE-configure)

# Build libsparse
m_build_target(libsparse libsparse CORE)
add_dependencies(libsparse libz libbase CORE-configure)

# Build libcutils
m_build_target(libcutils libcutils CORE)
add_dependencies(libcutils CORE-configure)

# Build liblog
m_build_target(liblog liblog CORE)
add_dependencies(liblog CORE-configure)

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
add_dependencies(mkbootimg CORE-configure)

# unpackbootimg
m_build_target(unpackbootimg unpackbootimg CORE)
add_dependencies(unpackbootimg CORE-configure)

# make_ext4fs
m_build_target(make_ext4fs make_ext4fs EXTRAS)
add_dependencies(make_ext4fs libz libselinux libsparse libcutils liblog EXTRAS-configure)

# Build sefcontext_compile
m_build_target(sefcontext_compile sefcontext_compile SELINUX)
add_dependencies(sefcontext_compile libpcre libselinux libsepol SELINUX-configure)

# Build sefcontext_decompile
m_build_target(sefcontext_decompile sefcontext_decompile SELINUX)
add_dependencies(sefcontext_decompile SELINUX-configure)

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
