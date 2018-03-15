# This file contains variables that change based on current configuration
# ============================================================
# ============================================================

# Current android version
message(STATUS "Building for Android Version ${ANDROID_VERSION}")

# Current android source
set(ANDROID_REPOSITORY_SOURCE ${DEFAULT_ANDROID_REPOSITORY_SOURCE} CACHE STRING "")
set_property(CACHE ANDROID_REPOSITORY_SOURCE PROPERTY STRINGS ${ALLOWED_ANDROID_REPOSITORY_SOURCE})

message(STATUS "Using source from ${ANDROID_REPOSITORY_SOURCE}")

# Current Android url and branch
include(Default-${ANDROID_REPOSITORY_SOURCE})
include(Macros)

foreach(module ${ANDROID_SUBMODULES})
    # Current Android url
    set(${module}_URL "" CACHE STRING "Leave blank to use the default repository url")
    m_set_if_defined(${module}_CURRENT_URL "${${module}_URL}" ${DEFAULT_${module}_URL})

    # Current Android branch
    set(${module}_BRANCH "" CACHE STRING "Leave blank to use the default branch. ${ANDROID_URL_HINT}")
    m_set_if_defined(${module}_CURRENT_BRANCH "${${module}_BRANCH}" ${DEFAULT_${module}_BRANCH})
endforeach()
