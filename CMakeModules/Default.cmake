# This file contains default variables
# ============================================================
# ============================================================

# Android version
set(ANDROID_VERSION 8)

# Default settings for AOSP and LINEAGE
# AOSP branch
set(DEFAULT_AOSP_BRANCH "android-8.1.0_r14")

# Lineage branch
# Can't use latest lineage branches cause of issue.
# Use hash commits instead
# https://gitlab.kitware.com/cmake/cmake/issues/16528
set(DEFAULT_LINEAGE_BRANCH "lineage-15.1")

# Android source
set(ALLOWED_ANDROID_REPOSITORY_SOURCE AOSP LINEAGE)
set(DEFAULT_ANDROID_REPOSITORY_SOURCE LINEAGE)

# Android libraries
set(ANDROID_SUBMODULES LIBZ PCRE SELINUX CORE EXTRAS)

# Android libraries prefix directory
set(ANDROID_PREFIX_DIR ${CMAKE_SOURCE_DIR}/external/platform)
set(ANDROID_BINARY_PREFIX_DIR ${CMAKE_BINARY_DIR}/external/platform)
set(EXTERNAL_MODULES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ExternalModules)

# Android libraries directories
foreach(module ${ANDROID_SUBMODULES})
    string(TOLOWER ${module} module_lower)

    # base directory
    set(${module}_DIR ${ANDROID_PREFIX_DIR}/${module_lower})
    
    # downloaded source directory
    set(${module}_SOURCE_DIR ${${module}_DIR}/src)

    # binary directory
    set(${module}_BINARY_DIR ${ANDROID_BINARY_PREFIX_DIR}/${module_lower})

    # relative path between source directory and base directory
    file(RELATIVE_PATH RELATIVE_${module}_SOURCE ${${module}_SOURCE_DIR} ${${module}_DIR})

    unset(module_lower)
endforeach()
