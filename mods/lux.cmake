register_target_properties(
    LUX_UNITS
    LUX
)

macro(get_lux_output var input)
    string(REPLACE ".lux" "" output ${input})
    set(${var} "${HERE_BIN}/${output}")
    debug("${input} => ${output} (${${var}})")
endmacro()
