# This file contains macros for the project
# ============================================================
# ============================================================

# set variable to var1 if defined else use default ARGV2 if supplied
macro(m_set_if_defined _name var1)
    if(${ARGC} GREATER 2)
        set(${_name} ${ARGV2})
    endif()
    if(${var1})
        set(${_name} ${var1})
    endif()
endmacro(m_set_if_defined)

# External project macro
macro(m_ExternalProject_Add _name)
    ExternalProject_Add(${_name}
        PREFIX ${${_name}_DIR}
        TMP_DIR ${${_name}_DIR}/tmp
        STAMP_DIR ${${_name}_DIR}/stamp
        DOWNLOAD_DIR ${${_name}_DIR}/download
        SOURCE_DIR ${${_name}_SOURCE_DIR}
        BINARY_DIR ${${_name}_BINARY_DIR}
        INSTALL_DIR ${${_name}_DIR}/install
        TIMEOUT 10
        GIT_REPOSITORY ${${_name}_CURRENT_URL}
        GIT_TAG ${${_name}_CURRENT_BRANCH}
        GIT_PROGRESS ON
        INSTALL_COMMAND ""
        TEST_COMMAND ""
        "${ARGN}"
    )
endmacro(m_ExternalProject_Add)

# Add clean step macro
macro(m_ExternalProject_CleanStep _name)
    ExternalProject_Add_Step(${_name} clean
        COMMAND ${CMAKE_COMMAND} --build . --target clean
        WORKING_DIRECTORY ${${_name}_BINARY_DIR}
        ALWAYS ON
        EXCLUDE_FROM_MAIN ON
    )
    ExternalProject_Add_StepTargets(${_name} clean)
endmacro(m_ExternalProject_CleanStep)

# Build target macro
macro(m_build_target _name _target _module)
    add_custom_target(${_name}
        ALL
        ${CMAKE_COMMAND} --build . --target ${_target}
        WORKING_DIRECTORY ${${_module}_BINARY_DIR}
        COMMENT "Building target ${_name} in ${_module}"
    )
endmacro(m_build_target)