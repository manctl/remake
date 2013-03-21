register_target_properties(
    PLATFORM_DEFS
)

set_global_and_local(PLATFORMS "WINDOWS;MACOSX;LINUX;UNIX")

foreach(platform ${PLATFORMS})
    register_target_properties(${platform}_SOURCES)
endforeach()

# Simplify the cross-platform model.
if(WIN32)
    set_internal(WINDOWS TRUE)
    append_global(PLATFORM_DEFS "SYS_WINDOWS")
elseif(UNIX)
    set_internal(UNIX TRUE)
    append_global(PLATFORM_DEFS "SYS_UNIX")
    if(APPLE)
        set_internal(MACOSX TRUE)
        append_global(PLATFORM_DEFS "SYS_MACOSX")
    else()
        set_internal(LINUX TRUE)
        append_global(PLATFORM_DEFS "SYS_LINUX")
    endif()
endif()

# Simplify the target cpu word length problem.
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set_internal(M64 ON)
else()
    set_internal(M32 ON)
endif()
