macro(register_target_properties first) # ...
    append_global(TARGET_PROPERTIES ${first} ${ARGN})
    debug("TARGET_PROPERTIES: ${first} ${ARGN}")
endmacro()

macro(load_target_properties target)
    get_global(TARGET_PROPERTIES)
    foreach(property ${TARGET_PROPERTIES})
        debug("${target}_${property}?")
        if(DEFINED ${target}_${property})
            set_global(${target}_${property} ${${target}_${property}})
            debug("${target}_${property} = ${${target}_${property}}")
        endif()
    endforeach()
endmacro()

macro(append_target_property target property value) # ...
    append_global(${target}_${property} ${value} ${ARGN})
    append(${target}_${property} ${value} ${ARGN})
endmacro()

macro(get_target_properties target)
    get_global(TARGET_PROPERTIES)
    foreach(property ${TARGET_PROPERTIES})
        get_global(${target}_${property})
        debug("${target}_${property} => ${${target}_${property}}")
    endforeach()
endmacro()
