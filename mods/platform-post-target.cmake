if(${T}_PLATFORM_DEFS)
    get_global(${PLATFORM_DEFS})
    set_property(TARGET ${T} APPEND PROPERTY COMPILE_DEFINITIONS
        ${PLATFORM_DEFS}
    )
endif()
