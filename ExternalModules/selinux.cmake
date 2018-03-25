#Custom CMake configuration for Android 8 (Oreo) Extras
cmake_minimum_required(VERSION 3.8)
project("Selinux" C CXX)

# External libraries
# ============================================================

set(libpcre "${PCRE_BINARY_DIR}/libpcre2-8.a")

# Compile Options
# ============================================================

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -std=c++11")

add_compile_options(-Werror)

set(libselinux_include ${SELINUX_SOURCE_DIR}/libselinux/include)
set(libselinux_utils ${SELINUX_SOURCE_DIR}/libselinux/utils)
set(libsepol_include
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src
    ${SELINUX_SOURCE_DIR}/libsepol/src
    ${SELINUX_SOURCE_DIR}/libsepol/cil/include
    ${SELINUX_SOURCE_DIR}/libsepol/include
)
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

set(libsepol_definitions
    -D_GNU_SOURCE
)

set(libsepol_options
    -Wall
    -W
    -Wundef
    -Wshadow
    -Wmissing-noreturn
    -Wmissing-format-attribute
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

set(LIBSEPOL_SRCS
    ${SELINUX_SOURCE_DIR}/libsepol/src/assertion.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/avrule_block.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/avtab.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/boolean_record.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/booleans.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/conditional.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/constraint.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/context.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/context_record.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/debug.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/ebitmap.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/expand.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/genbools.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/genusers.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/handle.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/hashtab.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/hierarchy.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/iface_record.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/interfaces.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/kernel_to_cil.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/kernel_to_common.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/kernel_to_conf.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/link.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/mls.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/module.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/module_to_cil.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/node_record.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/nodes.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/polcaps.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/policydb.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/policydb_convert.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/policydb_public.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/port_record.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/ports.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/roles.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/services.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/sidtab.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/symtab.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/user_record.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/users.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/util.c
    ${SELINUX_SOURCE_DIR}/libsepol/src/write.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/android.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_binary.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_build_ast.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_copy_ast.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_find.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_fqn.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_list.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_log.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_mem.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_parser.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_policy.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_post.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_reset_ast.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_resolve_ast.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_stack.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_strpool.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_symtab.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_tree.c
    ${SELINUX_SOURCE_DIR}/libsepol/cil/src/cil_verify.c
)

set(SEFCONTEXT_COMPILE_SRCS ${SELINUX_SOURCE_DIR}/libselinux/utils/sefcontext_compile.c)

set(SEFCONTEXT_DECOMPILE_SRCS ${CMAKE_SOURCE_DIR}/sefcontext_decompile.c)

# Build libraries
# ============================================================

# libselinux
add_library(libselinux STATIC ${LIBSELINUX_SRCS})
target_include_directories(libselinux PRIVATE ${libselinux_include} ${pcre_include})
target_compile_definitions(libselinux PRIVATE ${libselinux_definitions})
set_target_properties(libselinux PROPERTIES OUTPUT_NAME selinux)

#libsepol
add_library(libsepol STATIC ${LIBSEPOL_SRCS})
target_include_directories(libsepol PRIVATE ${libsepol_include})
target_compile_definitions(libsepol PRIVATE ${libsepol_definitions})
target_compile_options(libsepol PRIVATE ${libsepol_options})
set_target_properties(libsepol PROPERTIES OUTPUT_NAME sepol)

# Build Binaries
# ============================================================

#sefcontext_compile: file_contexts -> file_contexts.bin
add_executable(sefcontext_compile ${SEFCONTEXT_COMPILE_SRCS})
target_include_directories(sefcontext_compile PRIVATE ${libselinux_include} ${libsepol_include})

if(NOT EXISTS ${libpcre})
    message(WARNING "libpcre is missing.
    PCRE_BINARY_DIR: ${PCRE_BINARY_DIR} does not have libpcre.a")
endif()
target_link_libraries(sefcontext_compile libselinux libsepol ${libpcre})

#sefcontext_decompile: file_contexts.bin -> file_contexts
add_executable(sefcontext_decompile ${SEFCONTEXT_DECOMPILE_SRCS})
target_include_directories(sefcontext_decompile PRIVATE ${libselinux_utils} ${libselinux_include})