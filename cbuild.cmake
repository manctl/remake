# Simplify the cross-platform model.
if(WIN32)
    set(WINDOWS TRUE)
elseif(UNIX)
    if(APPLE)
        set(MACOSX TRUE)
    else()
        set(LINUX TRUE)
    endif()
endif()

# Beautify IDE projects.
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "[CMAKE]")

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
    set(CBUILD_STRICT_C_FLAGS   "-Wall -Wextra -Werror -ansi -std=c99   -pedantic -Wno-variadic-macros -Wno-long-long")
endif()

if(APPLE OR CMAKE_COMPILER_IS_GNUCXX)
    set(CBUILD_STRICT_CXX_FLAGS "-Wall -Wextra -Werror -ansi -std=c++98 -pedantic -Wno-variadic-macros -Wno-long-long")
endif()

macro(append l first) # ...
    list(APPEND ${l} ${first} ${ARGN})
endmacro()

macro(subdirs firstDir) # ...
    foreach(dir ${firstDir} ${ARGN})
        add_subdirectory(${dir})
    endforeach()
endmacro()

macro(target target_)
    project(${target_})
    set(HERE_BIN ${CMAKE_CURRENT_BINARY_DIR})
    set(HERE     ${CMAKE_CURRENT_SOURCE_DIR})
    include_directories(${HERE_BIN} ${HERE})
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
    if(${target}_CORE_QT_UNITS)
        foreach(unit ${${target}_CORE_QT_UNITS})
            append(${target}_MOC ${unit}.h)
            append(${target}_SOURCES
                ${unit}.cpp
                ${unit}.h
            )
        endforeach()
    endif()
    if(${target}_GUI_QT_UNITS)
        foreach(unit ${${target}_GUI_QT_UNITS})
            append(${target}_UIC ${unit}.ui)
            append(${target}_MOC ${unit}.h)
            append(${target}_SOURCES
                ${unit}.cpp
                ${unit}.h
            )
        endforeach()
    endif()
    if(${target}_MOC)
        QT4_WRAP_CPP(${target}_MOC_SOURCES ${${target}_MOC})
        append(${target}_SOURCES ${${target}_MOC_SOURCES})
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
