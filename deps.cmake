function(register_dep dep code)
    set_global(${dep}_DEP "${code}")
endfunction()

function(run_dep target dep)
    get_global(${dep}_DEP)
    if(NOT ${dep}_DEP)
        message(SEND_ERROR "Missing dependency: ${dep}")
    else()
        set(TARGET ${target})
        configure_inline(${target}-${dep}-dep ${${dep}_DEP})
    endif()
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

include_here(deps/gl-deps.cmake)
include_here(deps/qt-deps.cmake)
