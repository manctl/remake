set_global(REMAKE_MODS ${CMAKE_CURRENT_LIST_DIR}/../mods)

function(mod mod)
    get_global(REMAKE_MODS)
    include(${REMAKE_MODS}/${mod}.cmake)
endfunction()

function(mod_pre_target target mod)
    get_target_properties(${target})
    get_target_globals()
    get_global(REMAKE_MODS)
    include(${REMAKE_MODS}/${mod}-pre-target.cmake)
endfunction()

function(mod_post_target target mod)
    get_target_properties(${target})
    get_target_globals()
    get_global(REMAKE_MODS)
    include(${REMAKE_MODS}/${mod}-post-target.cmake)
endfunction()
