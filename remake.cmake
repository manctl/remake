# Trigger C & C++ compiler detection if necessary.
project(remake)

macro(include_here path) # paths
    include(${CMAKE_CURRENT_LIST_DIR}/${path})
endmacro()

include_here(core/output.cmake)
include_here(core/variables.cmake)

macro(subdirs firstDir) # ...
    foreach(dir ${firstDir} ${ARGN})
        add_subdirectory(${dir})
    endforeach()
endmacro()

macro(configure_inline name code)
# FIXME: Strangely, @VAR@-style expression have already been substituted here.
# Find out what's going on.
# See: http://www.cmake.org/pipermail/cmake/2013-March/053929.html
    string(REGEX REPLACE "%{([-A-Za-z_0-9]+)}" "\${\\1}" escaped_code "${code}")
#    string(CONFIGURE "${escaped_code}" configured_code @ONLY)
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${name}.cmake "${escaped_code}")
    include(${CMAKE_CURRENT_BINARY_DIR}/${name}.cmake)
endmacro()

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

set_global(PLATFORMS "WINDOWS;MACOSX;LINUX;UNIX")

# Simplify the target cpu word length problem.
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set_internal(M64 ON)
else()
    set_internal(M32 ON)
endif()

# Beautify IDE projects.
set_global(USE_FOLDERS ON)
set_global(PREDEFINED_TARGETS_FOLDER "[CMAKE]")

# Put sources in folders.
if(CMAKE_GENERATOR MATCHES "Visual Studio")
    macro(folderify_sources src0) # ...
        source_group("Output" REGULAR_EXPRESSION "\\.rule$")
        foreach(src ${src0} ${ARGN})
            get_filename_component(folder ${src} PATH)
            if(NOT folder)
                set(folder "/")
            elseif(IS_ABSOLUTE ${folder})
                string(REGEX REPLACE "^${CMAKE_CURRENT_BINARY_DIR}.*" "Output" folder ${folder})
                string(REGEX REPLACE "^${CMAKE_CURRENT_SOURCE_DIR}/?" "/" folder ${folder})
            else()
                set(folder "/${folder}")
            endif()
            debug("${src} => ${folder}")
            source_group(${folder} FILES ${src})
        endforeach()
    endmacro()
else()
    macro(folderify_sources src0) # ...
    endmacro()
endif()

if(APPLE OR CMAKE_COMPILER_IS_GNUC)
    set(REMAKE_STRICT_C_FLAGS   "-Wall -Wextra -Werror -ansi -std=c99   -pedantic -Wno-variadic-macros -Wno-long-long -Wno-unknown-pragmas")
endif()

if(APPLE OR CMAKE_COMPILER_IS_GNUCXX)
    set(REMAKE_STRICT_CXX_FLAGS "-Wall -Wextra -Werror -ansi -std=c++98 -pedantic -Wno-variadic-macros -Wno-long-long -Wno-unknown-pragmas")
endif()

macro(dirname var path)
    get_filename_component(${var} ${path} PATH)
endmacro()

macro(add_compile_flags flag0) # ...
    set_property(DIRECTORY APPEND PROPERTY COMPILE_FLAGS ${flag0} ${ARGN})
endmacro()

set_global_and_local(REMAKE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set_global_and_local(HERE_BIN ${CMAKE_CURRENT_BINARY_DIR})

macro(target name)
    project(${name})
    set_global_and_local(T    ${name})
    set_global_and_local(HERE ${CMAKE_CURRENT_SOURCE_DIR})
    set_global_and_local(HERE_BIN ${CMAKE_CURRENT_BINARY_DIR})
    include_directories(${HERE_BIN} ${HERE})
endmacro()

macro(get_remake_globals)
    get_global(T)
    get_global(HERE)
    get_global(HERE_BIN)
endmacro()

macro(remake_properties first) # second ... last
    append_global(REMAKE_PROPERTIES ${first} ${ARGN})
    debug("REMAKE_PROPERTIES: ${first} ${ARGN}")
endmacro()

remake_properties(
    SOURCES
    GENERATED
    UNITS
    HPP_UNITS
    WIN32_RC
    FILES
    DEPS
    FILENAME
    DEFS
    PLATFORM_DEFS
    COMPILE_FLAGS
    STRICT
    INCLUDES
    FLAGS
    LIBS
    LIBS_OPTIMIZED
    LIBS_DEBUG
)

macro(set_remake_properties target)
    get_global(REMAKE_PROPERTIES)
    foreach(property ${REMAKE_PROPERTIES})
        debug("${target}_${property}?")
        if(DEFINED ${target}_${property})
            set_global(${target}_${property} ${${target}_${property}})
            debug("${target}_${property} = ${${target}_${property}}")
        endif()
    endforeach()
endmacro()

macro(get_remake_properties target)
    get_global(REMAKE_PROPERTIES)
    foreach(property ${REMAKE_PROPERTIES})
        get_global(${target}_${property})
        debug("${target}_${property} => ${${target}_${property}}")
    endforeach()
endmacro()

macro(get_remake_variables target)
    get_remake_globals()
    get_remake_properties(${target})
endmacro()

macro(register_target_files target KIND kind)
    set(${kind}_files_h ${CMAKE_CURRENT_BINARY_DIR}/${target}-${kind}-files.h)
    dir2code(${${kind}_files_h} ${${target}_${KIND}})
    set(${kind}_files_cpp ${CMAKE_CURRENT_BINARY_DIR}/${target}-${kind}-files.cpp)
    dir2code(${${kind}_files_cpp} ${${target}_${KIND}})
    append(${target}_SOURCES
        ${${kind}_files_h}
        ${${kind}_files_cpp}
    )
    append(${target}_GENERATED
        ${${kind}_files_h}
        ${${kind}_files_cpp}
    )
endmacro(register_target_files)

macro(platform_specific_sources target platform0) # ...
    foreach(platform ${platform0} ${ARGN})
        if(${platform} AND ${target}_${platform}_SOURCES)
            append(${target}_SOURCES ${${target}_${platform}_SOURCES})
        endif()
    endforeach()
endmacro()

include_here(mods.cmake)

macro(pre_target target)

    set_remake_properties(${target})
    mods_pre_target(${target})
    get_remake_properties(${target})

    get_global(PLATFORMS)
    platform_specific_sources(${target} ${PLATFORMS})

    if(${target}_UNITS)
        foreach(unit ${${target}_UNITS})
            append(${target}_SOURCES
                ${unit}.cpp
                ${unit}.h
            )
        endforeach()
    endif()
    if(${target}_HPP_UNITS)
        foreach(unit ${${target}_HPP_UNITS})
            append(${target}_SOURCES
                ${unit}.cpp
                ${unit}.h
                ${unit}.hpp
            )
        endforeach()
    endif()
    if(WIN32 AND ${target}_WIN32_RC)
        append(${target}_SOURCES ${${target}_WIN32_RC})
    endif()
    if(${target}_FILES)
        foreach(file ${${target}_FILES})
            append(${target}_SOURCES ${file})
        endforeach()
    endif()
    if(${target}_SOURCES)
        folderify_sources(${${target}_SOURCES})
    endif()
endmacro()

macro(get_source_language src var)
    if(src MATCHES "\\.c$")
        set(${var} C)
    elseif(src MATCHES "\\.cpp$")
        set(${var} CXX)
    else()
        set(${var})
    endif()
endmacro()

macro(post_target target)

    set_remake_properties(${target})
    mods_post_target(${target})
    get_remake_properties(${target})

    foreach(dep ${${target}_DEPS})
        run_dep(${target} ${dep})
    endforeach()

    if(${target}_FILENAME)
        set_property(TARGET ${target} PROPERTY OUTPUT_NAME ${${target}_FILENAME})
    endif()
    if(${target}_DEFS)
        set_property(TARGET ${target} APPEND PROPERTY COMPILE_DEFINITIONS ${${target}_DEFS})
    endif()
    if(${target}_PLATFORM_DEFS)
        get_global(${PLATFORM_DEFS})
        set_property(TARGET ${target} APPEND PROPERTY COMPILE_DEFINITIONS ${PLATFORM_DEFS})
    endif()
    if(${target}_COMPILE_FLAGS)
        set_property(TARGET ${target} APPEND PROPERTY COMPILE_FLAGS ${${target}_COMPILE_FLAGS})
    endif()
    if(${target}_STRICT)
        foreach(src ${${target}_SOURCES})
            get_source_language(${src} src_lang)
            if(src_lang STREQUAL "C" AND DEFINED REMAKE_STRICT_C_FLAGS)
                set_property(SOURCE ${src} APPEND PROPERTY COMPILE_FLAGS ${REMAKE_STRICT_C_FLAGS})
            elseif(src_lang STREQUAL "CXX" AND DEFINED REMAKE_STRICT_CXX_FLAGS)
                set_property(SOURCE ${src} APPEND PROPERTY COMPILE_FLAGS ${REMAKE_STRICT_CXX_FLAGS})
            endif()
        endforeach()
    endif()
    if(${target}_INCLUDES)
        foreach(path ${${target}_INCLUDES})
            get_filename_component(real_path ${path} REALPATH)
            set_property(TARGET ${target} APPEND PROPERTY INCLUDE_DIRECTORIES ${real_path})
        endforeach()
    endif()
    if(${target}_FILES)
        foreach(file ${${target}_FILES})
            set_property(SOURCE ${file} PROPERTY HEADER_FILE_ONLY TRUE)
        endforeach()
    endif()
    if(${target}_GENERATED)
        foreach(file ${${target}_GENERATED})
            append(${target}_SOURCES ${file})
            set_property(SOURCE ${file} PROPERTY GENERATED TRUE)
        endforeach()
    endif()
endmacro()

macro(link_platforms target platform0) # ...
    foreach(platform ${platform0} ${ARGN})
        if(${platform} AND ${target}_${platform}_LIBS)
            target_link_libraries(${target} ${${target}_${platform}_LIBS})
        endif()
    endforeach()
endmacro()

macro(link target)
    get_global(PLATFORMS)
    link_platforms(${target} ${PLATFORMS})

    if(${target}_LIBS)
        target_link_libraries(${target} ${${target}_LIBS})
    endif()

    if(${target}_LIBS_DEBUG)
        target_link_libraries(${target} debug ${${target}_LIBS_DEBUG})
    endif()

    if(${target}_LIBS_OPTIMIZED)
        target_link_libraries(${target} optimized ${${target}_LIBS_OPTIMIZED})
    endif()
endmacro()

macro(build_executable target) # ...
    pre_target(${target})
    add_executable(${target} ${ARGN}
        ${${target}_SOURCES}
    )
    post_target(${target})
    link(${target})
    set_property(TARGET ${target} PROPERTY FOLDER "exes")
endmacro()

macro(build_static_library target)
    pre_target(${target})
    add_library(${target} STATIC
        ${${target}_SOURCES}
    )
    post_target(${target})
    link(${target})
    set_property(TARGET ${target} PROPERTY FOLDER "libs")
    register_library_dep(${target})
endmacro()

macro(build_shared_library target)
    pre_target(${target})
    add_library(${target} SHARED
        ${${target}_SOURCES}
    )
    post_target(${target})
    link(${target})
    set_property(TARGET ${target} PROPERTY FOLDER "dlls")
    register_library_dep(${target})
endmacro()

macro(build_module target) # ...
    pre_target(${target})
    add_library(${target} MODULE ${ARGN}
        ${${target}_SOURCES}
    )
    post_target(${target})
    link(${target})
    set_property(TARGET ${target} PROPERTY FOLDER "mods")
endmacro()

macro(build_application target) # ...
    # FIXME: Add WIN32 & proper dispatch dispatch between:
    #   * Qt's WinMain for Qt applications,
    #   * and /ENTRY:mainCRTStartup linker flag for non-qt applications.
    build_executable(${target} MACOSX_BUNDLE ${ARGN})
    set_property(TARGET ${target} PROPERTY FOLDER "apps")
endmacro()

macro(build_server target)
    pre_target(${target})
    add_executable(${target} ${ARGN}
        ${${target}_SOURCES}
    )
    post_target(${target})
    link(${target})
    set_property(TARGET ${target} PROPERTY FOLDER "webs")
endmacro()

include_here(deps.cmake)
