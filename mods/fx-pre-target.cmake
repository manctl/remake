if(${T}_FX_UNITS)
    foreach(unit ${${T}_FX_UNITS})
        append_target_property(${T} SOURCES
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
                append_target_property(${T} SOURCES ${unit}${suffix})
            endif()
        endforeach()
    endforeach()
endif()
