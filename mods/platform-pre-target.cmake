get_global(PLATFORMS)
foreach(platform ${PLATFORMS})
    if(${platform} AND ${T}_${platform}_SOURCES)
        append_target_property(${T} SOURCES ${${T}_${platform}_SOURCES})
    endif()
endforeach()
