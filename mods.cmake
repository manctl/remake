mod(workspace)
mod(platform)
mod(strict)
mod(units)
mod(qt)

macro(mods_pre_target target)
    # Order matters. Current dependencies: none.
    mod_pre_target(${target} platform)
    mod_pre_target(${target} units)
    mod_pre_target(${target} qt)
endmacro()

macro(mods_post_target target)
    # Order matters. Current dependencies: none.
    mod_post_target(${target} platform)
    mod_post_target(${target} strict)
endmacro()
