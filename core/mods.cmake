set_global(REMAKE_MODS ${CMAKE_CURRENT_LIST_DIR}/../mods)

macro(mod mod)
    get_global(REMAKE_MODS)
    include(${REMAKE_MODS}/${mod}.cmake)
endmacro()

macro(mod_pre_target target mod)
    get_global(REMAKE_MODS)
    set(target ${target})
    include(${REMAKE_MODS}/${mod}-pre-target.cmake)
endmacro()

macro(mod_post_target target mod)
    get_global(REMAKE_MODS)
    set(target ${target})
    include(${REMAKE_MODS}/${mod}-post-target.cmake)
endmacro()
