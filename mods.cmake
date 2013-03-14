include_here(core/mods.cmake)

mod(qt)
mod(workspace)

macro(mods_pre_target target)
    # Order matters. Current dependencies: none.
    mod_pre_target(${target} qt)
endmacro()

macro(mods_post_target target)
    # Order matters. Current dependencies: none.
endmacro()
