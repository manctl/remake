macro(append l first) # ...
    if(NOT DEFINED ${l})
        set(${l})
    endif()
    list(APPEND ${l} ${first} ${ARGN})
endmacro()

macro(get_global var)
    get_property(${var} GLOBAL PROPERTY ${var})
endmacro()

function(set_global var val) # ...
    set_property(GLOBAL PROPERTY ${var} ${val} ${ARGN})
    debug("GLOBAL: ${var} = ${val} ${ARGN}")
endfunction()

function(append_global var first) # second ... last
    get_global(${var})
    list(APPEND ${var} ${first} ${ARGN})
    debug("list(APPEND ${var} ${first} ${ARGN})")
    set_global(${var} ${${var}})
endfunction()

macro(set_global_and_local var val)
    set_global(${var} ${val})
    set(${var} ${val})
endmacro()

function(set_internal var val)
    set(${var} ${val} CACHE INTERNAL "")
endfunction()
