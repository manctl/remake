macro(append l first) # ...
    list(APPEND ${l} ${first} ${ARGN})
endmacro()

macro(subdirs firstDir) # ...
    foreach(dir ${firstDir} ${ARGN})
        add_subdirectory(${dir})
    endforeach()
endmacro()

macro(debug_var var)
    message("${var}=${${var}}")
endmacro()

macro(configure_inline name code)
# FIXME: Strangely, @VAR@-style expression have already been substituted here.
# Find out what's going on.
    string(REGEX REPLACE "%{([-A-Za-z_0-9]+)}" "\${\\1}" escaped_code "${code}")
#    string(CONFIGURE "${escaped_code}" configured_code @ONLY)
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${name}.cmake "${escaped_code}")
    include(${CMAKE_CURRENT_BINARY_DIR}/${name}.cmake)
endmacro()

macro(set_global var val)
    set_property(GLOBAL PROPERTY ${var} ${val})
endmacro()

macro(get_global var)
    get_property(${var} GLOBAL PROPERTY ${var})
endmacro()

macro(append_global var first) # second ... last
    get_global(${var})
    list(APPEND ${var} ${first} ${ARGN})
    set_global(${var} ${${var}})
endmacro()

# Simplify the cross-platform model.
if(WIN32)
    set(WINDOWS TRUE)
    append_global(PLATFORM_DEFS "SYS_WINDOWS")
elseif(UNIX)
    append_global(PLATFORM_DEFS "SYS_UNIX")
    if(APPLE)
        set(MACOSX TRUE)
        append_global(PLATFORM_DEFS "SYS_MACOSX")
    else()
        set(LINUX TRUE)
        append_global(PLATFORM_DEFS "SYS_LINUX")
    endif()
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
            # message("${src} => ${folder}")
            source_group(${folder} FILES ${src})
        endforeach()
    endmacro()
else()
    macro(folderify_sources src0) # ...
    endmacro()
endif()

if(APPLE OR CMAKE_COMPILER_IS_GNUC)
    set(CBUILD_STRICT_C_FLAGS   "-Wall -Wextra -Werror -ansi -std=c99   -pedantic -Wno-variadic-macros -Wno-long-long -Wno-unknown-pragmas")
endif()

if(APPLE OR CMAKE_COMPILER_IS_GNUCXX)
    set(CBUILD_STRICT_CXX_FLAGS "-Wall -Wextra -Werror -ansi -std=c++98 -pedantic -Wno-variadic-macros -Wno-long-long -Wno-unknown-pragmas")
endif()

macro(dirname var path)
    get_filename_component(${var} ${path} PATH)
endmacro()

macro(target target_)
    project(${target_})
    set(HERE_BIN ${CMAKE_CURRENT_BINARY_DIR})
    set(HERE     ${CMAKE_CURRENT_SOURCE_DIR})
    include_directories(${HERE_BIN} ${HERE})
endmacro()

macro(get_lux_output var input)
    string(REPLACE ".lux" "" output ${input})
    set(${var} "${CMAKE_CURRENT_BINARY_DIR}/${output}")
    # message("${input} => ${output} (${${var}})")
endmacro()

macro(pre_target target)
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
    if(${target}_MOC_UNITS)
        foreach(unit ${${target}_MOC_UNITS})
            append(${target}_MOC ${unit}.h)
            append(${target}_SOURCES
                ${unit}.cpp
                ${unit}.h
            )
        endforeach()
    endif()
    if(${target}_UIC_UNITS)
        foreach(unit ${${target}_UIC_UNITS})
            append(${target}_UIC ${unit}.ui)
            append(${target}_MOC ${unit}.h)
            append(${target}_SOURCES
                ${unit}.cpp
                ${unit}.h
            )
        endforeach()
    endif()
    if(${target}_LUX)
        foreach(lux ${${target}_LUX})
            get_lux_output(lux_output ${lux})
            lux(${lux} ${lux_output})
            # message("LUX: ${lux} -> ${lux_output}")
        endforeach()
    endif()
    if(${target}_MOC)
        QT4_WRAP_CPP(${target}_MOC_SOURCES ${${target}_MOC})
        append(${target}_SOURCES ${${target}_MOC_SOURCES})
    endif()
    if(${target}_JS)
        set(js_qrc ${CMAKE_CURRENT_BINARY_DIR}/${target}-js.qrc)
        dir2code(${js_qrc} ${${target}_JS})
        append(${target}_QRC ${js_qrc})
        append(${target}_FILES ${${target}_JS})
    endif()
    if(${target}_QML)
        set(qmldir ${CMAKE_CURRENT_BINARY_DIR}/qmldir)
        dir2code(${qmldir} ${${target}_QML})
        set(qml_qrc ${CMAKE_CURRENT_BINARY_DIR}/${target}-qml.qrc)
        dir2code(${qml_qrc} ${${target}_QML} ${qmldir})
        append(${target}_QRC ${qml_qrc})
        append(${target}_FILES ${${target}_QML} ${qmldir})
    endif()
    if(${target}_GFX)
        set(gfx_qrc ${CMAKE_CURRENT_BINARY_DIR}/${target}-gfx.qrc)
        dir2code(${gfx_qrc} ${${target}_GFX})
        append(${target}_QRC ${gfx_qrc})
        append(${target}_FILES ${${target}_GFX})
    endif()
    if(${target}_QRC)
        QT4_ADD_RESOURCES(${target}_QRC_SOURCES ${${target}_QRC})
        append(${target}_SOURCES ${${target}_QRC} ${${target}_QRC_SOURCES})
    endif()
    if(${target}_UIC)
        QT4_WRAP_UI(${target}_UIC_SOURCES ${${target}_UIC})
        append(${target}_SOURCES ${${target}_UIC} ${${target}_UIC_SOURCES})
    endif()
    if(WIN32 AND ${target}_WIN32_RC)
        append(${target}_SOURCES ${${target}_WIN32_RC})
    endif()
    if(${target}_FILES)
        foreach(file ${${target}_FILES})
            append(${target}_SOURCES ${file})
            set_property(SOURCE ${file} PROPERTY HEADER_FILE_ONLY TRUE)
        endforeach()
    endif()
    folderify_sources(${${target}_SOURCES})
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
    if(${target}_STRICT)
        foreach(src ${${target}_SOURCES})
            get_source_language(${src} src_lang)
            if(src_lang STREQUAL "C" AND DEFINED CBUILD_STRICT_C_FLAGS)
                set_property(SOURCE ${src} APPEND PROPERTY COMPILE_FLAGS ${CBUILD_STRICT_C_FLAGS})
            elseif(src_lang STREQUAL "CXX" AND DEFINED CBUILD_STRICT_CXX_FLAGS)
                set_property(SOURCE ${src} APPEND PROPERTY COMPILE_FLAGS ${CBUILD_STRICT_CXX_FLAGS})
            endif()
        endforeach()
    endif()
    if(${target}_FILENAME)
        set_property(TARGET ${target} PROPERTY OUTPUT_NAME ${${target}_FILENAME})
    endif()
    foreach(dep ${${target}_DEPS})
        run_dep(${target} ${dep})
    endforeach()
    if(${target}_PLATFORM_DEFS)
        get_global(${PLATFORM_DEFS})
        set_property(TARGET ${target} PROPERTY COMPILE_DEFINITIONS ${PLATFORM_DEFS})
    endif()
endmacro()

macro(link_platforms target first_platform) # ...
    foreach(platform ${first_platform} ${ARGN})
        if(${platform} AND ${target}_LIBS_${platform})
            target_link_libraries(${target} ${${target}_LIBS_${platform}})
        endif()
    endforeach()
endmacro()

macro(link target)
    link_platforms(${target}
        WINDOWS
        MACOSX
        LINUX
        UNIX
    )

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

macro(build_application target) # ...
    # FIXME: Add WIN32 & proper dispatch dispatch between:
    #   * Qt's WinMain for Qt applications,
    #   * and /ENTRY:mainCRTStartup linker flag for non-qt applications.
    build_executable(${target} MACOSX_BUNDLE ${ARGN})
    set_property(TARGET ${target} PROPERTY FOLDER "apps")
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

macro(build_server target)
    pre_target(${target})
    add_executable(${target} ${ARGN}
        ${${target}_SOURCES}
    )
    post_target(${target})
    link(${target})
    set_property(TARGET ${target} PROPERTY FOLDER "webs")
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

macro(begin_workspace)
    set(workspace_cpp ${CMAKE_CURRENT_BINARY_DIR}/workspace.cpp)
    file(WRITE ${workspace_cpp} "// Dummy translation unit.\n")
    set_property(GLOBAL PROPERTY workspace_FILES ${workspace_cpp})
endmacro()

macro(add_to_workspace first_workspace_file) # ...
    foreach(workspace_file ${first_workspace_file} ${ARGN})
        set_property(GLOBAL APPEND PROPERTY workspace_FILES
            ${CMAKE_CURRENT_SOURCE_DIR}/${workspace_file}
        )
    endforeach()
endmacro()

macro(end_workspace)
    get_property(workspace_FILES GLOBAL PROPERTY workspace_FILES)
    set_property(SOURCE ${workspace_FILES} PROPERTY HEADER_FILE_ONLY TRUE)
    folderify_sources(${workspace_FILES})
    add_library(workspace ${workspace_FILES})
    set_property(TARGET workspace PROPERTY EXCLUDE_FROM_ALL TRUE)
    set_property(TARGET workspace PROPERTY FOLDER "[CBUILD]")
endmacro()

macro(include_here path) # paths
    get_filename_component(HERE ${CMAKE_CURRENT_LIST_FILE} PATH)
    include(${HERE}/${path})
endmacro()

include_here(deps.cmake)
