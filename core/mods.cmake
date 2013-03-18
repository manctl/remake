set_global(REMAKE_MODS ${CMAKE_CURRENT_LIST_DIR}/../mods)

macro(target_append target property value) # ...
    append_global(${target}_${property} ${value} ${ARGN})
    append(${target}_${property} ${value} ${ARGN})
endmacro()

function(mod mod)
    get_global(REMAKE_MODS)
    include(${REMAKE_MODS}/${mod}.cmake)
endfunction()

function(mod_pre_target target mod)
    get_global(REMAKE_MODS)
    get_remake_variables(${target})
    include(${REMAKE_MODS}/${mod}-pre-target.cmake)
    set_remake_properties(${target})
endfunction()

function(mod_post_target target mod)
    get_global(REMAKE_MODS)
    get_remake_variables(${target})
    include(${REMAKE_MODS}/${mod}-post-target.cmake)
    set_remake_properties(${target})
endfunction()
