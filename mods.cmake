include_here(core/mods.cmake)

mod(qt)
mod(fx)
mod(lux)
mod(workspace)

macro(mods_pre_target target)
    # Order matters. Current dependencies: lux -> qt.
    mod_pre_target(${target} fx)
    mod_pre_target(${target} lux)
    mod_pre_target(${target} qt)
endmacro()

macro(mods_post_target target)
    # Order matters. Current dependencies: none.
endmacro()
