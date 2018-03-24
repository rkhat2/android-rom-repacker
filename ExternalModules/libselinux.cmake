# Custom CMake configuration for Android 6 (Marshmallow) Libselinux
cmake_minimum_required(VERSION 3.8)
project("Libselinux" C)

# Compile Options
# ============================================================

add_compile_options(-Werror)

set(libselinux_include ${LIBSELINUX_SOURCE_DIR}/include)

set(libselinux_definitions -DHOST -DAUDITD_LOG_TAG=1003 -D_GNU_SOURCE)

# Sources
# ============================================================
set(LIBSELINUX_SRCS
    ${LIBSELINUX_SOURCE_DIR}/src/booleans.c
    ${LIBSELINUX_SOURCE_DIR}/src/canonicalize_context.c
    ${LIBSELINUX_SOURCE_DIR}/src/disable.c
    ${LIBSELINUX_SOURCE_DIR}/src/enabled.c
    ${LIBSELINUX_SOURCE_DIR}/src/fgetfilecon.c
    ${LIBSELINUX_SOURCE_DIR}/src/fsetfilecon.c
    ${LIBSELINUX_SOURCE_DIR}/src/getenforce.c
    ${LIBSELINUX_SOURCE_DIR}/src/getfilecon.c
    ${LIBSELINUX_SOURCE_DIR}/src/getpeercon.c
    ${LIBSELINUX_SOURCE_DIR}/src/lgetfilecon.c
    ${LIBSELINUX_SOURCE_DIR}/src/load_policy.c
    ${LIBSELINUX_SOURCE_DIR}/src/lsetfilecon.c
    ${LIBSELINUX_SOURCE_DIR}/src/policyvers.c
    ${LIBSELINUX_SOURCE_DIR}/src/procattr.c
    ${LIBSELINUX_SOURCE_DIR}/src/setenforce.c
    ${LIBSELINUX_SOURCE_DIR}/src/setfilecon.c
    ${LIBSELINUX_SOURCE_DIR}/src/context.c
    ${LIBSELINUX_SOURCE_DIR}/src/mapping.c
    ${LIBSELINUX_SOURCE_DIR}/src/stringrep.c
    ${LIBSELINUX_SOURCE_DIR}/src/compute_create.c
    ${LIBSELINUX_SOURCE_DIR}/src/compute_av.c
    ${LIBSELINUX_SOURCE_DIR}/src/avc.c
    ${LIBSELINUX_SOURCE_DIR}/src/avc_internal.c
    ${LIBSELINUX_SOURCE_DIR}/src/avc_sidtab.c
    ${LIBSELINUX_SOURCE_DIR}/src/get_initial_context.c
    ${LIBSELINUX_SOURCE_DIR}/src/checkAccess.c
    ${LIBSELINUX_SOURCE_DIR}/src/sestatus.c
    ${LIBSELINUX_SOURCE_DIR}/src/deny_unknown.c
)
set(LIBSELINUX_HOSTS
    ${LIBSELINUX_SOURCE_DIR}/src/callbacks.c
    ${LIBSELINUX_SOURCE_DIR}/src/check_context.c
    ${LIBSELINUX_SOURCE_DIR}/src/freecon.c
    ${LIBSELINUX_SOURCE_DIR}/src/init.c
    ${LIBSELINUX_SOURCE_DIR}/src/label.c
    ${LIBSELINUX_SOURCE_DIR}/src/label_file.c
    ${LIBSELINUX_SOURCE_DIR}/src/label_android_property.c
)

# Build libraries
# ============================================================

add_library(libselinux STATIC ${LIBSELINUX_SRCS} ${LIBSELINUX_HOSTS})
target_include_directories(libselinux PRIVATE ${libselinux_include})
target_compile_definitions(libselinux PRIVATE ${libselinux_definitions})
set_target_properties(libselinux PROPERTIES OUTPUT_NAME selinux)
