function(debug txt) # ...
#    message(${txt} ${ARGN})
endfunction()

macro(debug_var var)
    debug("${var}=${${var}}")
endmacro()
