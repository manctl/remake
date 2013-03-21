if(${T}_UNITS)
    foreach(unit ${${T}_UNITS})
        append_target_property(${T} SOURCES
            ${unit}.cpp
            ${unit}.h
        )
    endforeach()
endif()
if(${T}_HPP_UNITS)
    foreach(unit ${${T}_HPP_UNITS})
        append_target_property(${T} SOURCES
            ${unit}.cpp
            ${unit}.h
            ${unit}.hpp
        )
    endforeach()
endif()
