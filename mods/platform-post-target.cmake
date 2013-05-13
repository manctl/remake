if(${T}_PLATFORM_DEFS)
    get_global(PLATFORM_DEFS)
    if(NOT DEFINED PLATFORM_DEFS)
        message(FATAL_ERROR "Internal error: No platform definitions.")
    endif()
    set_property(TARGET ${T} APPEND PROPERTY COMPILE_DEFINITIONS
        ${PLATFORM_DEFS}
    )
endif()
