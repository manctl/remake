if(${T}_LUX_UNITS)
    foreach(unit ${${T}_LUX_UNITS})
        get_lux_output(output_h   ${unit}.lux.h)
        get_lux_output(output_cpp ${unit}.lux.cpp)
        append_target_property(${T} LUX
            ${unit}.lux.h
            ${unit}.lux.cpp
        )
        append_target_property(${T} MOC
            ${output_h}
        )
        append_target_property(${T} SOURCES
            ${output_h}
            ${output_cpp}
        )
        append_target_property(${T} FILES
            ${unit}.lux.h
            ${unit}.lux.cpp
        )
    endforeach()
endif()
if(${T}_LUX)
    foreach(lux ${${T}_LUX})
        get_lux_output(lux_output ${lux})
        lux(${lux} ${lux_output})
        append_target_property(${T} GENERATED ${lux_output})
        debug("LUX: ${lux} -> ${lux_output}")
    endforeach()
endif()
