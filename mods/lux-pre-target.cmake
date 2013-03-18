if(${T}_LUX_UNITS)
    foreach(unit ${${T}_LUX_UNITS})
        get_lux_output(output_h   ${unit}.lux.h)
        get_lux_output(output_cpp ${unit}.lux.cpp)
        target_append(${T} LUX
            ${unit}.lux.h
            ${unit}.lux.cpp
        )
        target_append(${T} MOC
            ${output_h}
        )
        target_append(${T} SOURCES
            ${output_h}
            ${output_cpp}
        )
        target_append(${T} FILES
            ${unit}.lux.h
            ${unit}.lux.cpp
        )
    endforeach()
endif()
if(${T}_LUX)
    foreach(lux ${${T}_LUX})
        get_lux_output(lux_output ${lux})
        lux(${lux} ${lux_output})
        target_append(${T} GENERATED ${lux_output})
        message("LUX: ${lux} -> ${lux_output}")
    endforeach()
endif()
