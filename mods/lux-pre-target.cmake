if(${target}_LUX_UNITS)
    foreach(unit ${${target}_LUX_UNITS})
        get_lux_output(output_h   ${unit}.lux.h)
        get_lux_output(output_cpp ${unit}.lux.cpp)
        append(${target}_LUX
            ${unit}.lux.h
            ${unit}.lux.cpp
        )
        append(${target}_MOC ${output_h})
        append(${target}_SOURCES
            ${output_h}
            ${output_cpp}
        )
        append(${target}_FILES
            ${unit}.lux.h
            ${unit}.lux.cpp
        )
    endforeach()
endif()
if(${target}_LUX)
    foreach(lux ${${target}_LUX})
        get_lux_output(lux_output ${lux})
        lux(${lux} ${lux_output})
        append(${target}_GENERATED ${lux_output})
        # message("LUX: ${lux} -> ${lux_output}")
    endforeach()
endif()
