set_global(CBUILD_MODS ${CMAKE_CURRENT_LIST_DIR}/../mods)

macro(mod mod)
    get_global(CBUILD_MODS)
    include(${CBUILD_MODS}/${mod}.cmake)
endmacro()

macro(mod_pre_target target mod)
    get_global(CBUILD_MODS)
    set(target ${target})
    include(${CBUILD_MODS}/${mod}-pre-target.cmake)
endmacro()

macro(mod_post_target target mod)
    get_global(CBUILD_MODS)
    set(target ${target})
    include(${CBUILD_MODS}/${mod}-post-target.cmake)
endmacro()
