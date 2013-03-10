function(register_dep dep code)
    set_global(${dep}_DEP "${code}")
endfunction()

function(register_dep_alias alias dep)
    set_global(${alias}_DEP ":${dep}")
endfunction()

function(register_library_dep lib)
    register_dep(${lib} "
include_directories(
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)
target_link_libraries(@TARGET@ ${lib})
")
endfunction()

function(register_library_package_dep name package libs_var)
    register_dep(${name} "
find_package(${package} REQUIRED)
target_link_libraries(@TARGET@ %{${libs_var}})
")
endfunction()

function(run_dep target dep)
    get_global(${dep}_DEP)
    if(NOT ${dep}_DEP)
        message(SEND_ERROR "Missing dependency: ${dep}")
    else()
        if(${dep}_DEP MATCHES "^:")
            string(REGEX REPLACE "^:(.*)$" "\\1" alias "${${dep}_DEP}")
            message("DEP ALIAS: ${dep} -> ${alias}")
            run_dep(${target} ${alias})
        else()
            set(TARGET ${target})
            configure_inline(${target}-${dep}-dep ${${dep}_DEP})
        endif()
    endif()
endfunction()

file(GLOB_RECURSE deps RELATIVE ${CMAKE_CURRENT_LIST_DIR} "${CMAKE_CURRENT_LIST_DIR}/deps/*.cmake")

foreach(dep ${deps})
    include_here(${dep})
endforeach()
