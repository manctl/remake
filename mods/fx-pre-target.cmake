if(${target}_FX_UNITS)
    foreach(unit ${${target}_FX_UNITS})
        append(${target}_SOURCES
            ${unit}-fx.cpp
            ${unit}-fx.h
        )
        set(UNIT_SUFFIXES
            -fx.lua
            -fx-sys.lua
            -fx-ctl.lua
            -fx-gui.lua
            -fx-gfx.lua
        )
        foreach(suffix ${UNIT_SUFFIXES})
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${unit}${suffix}")
                append(${target}_SOURCES ${unit}${suffix})
            endif()
        endforeach()
    endforeach()
endif()
