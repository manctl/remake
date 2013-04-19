# Trigger C & C++ compiler detection if necessary.
if(NOT CMAKE_CXX_COMPILER)
    # This will confuse QtCreator's current (2.6.1) .cbp detection,
    # and override the project name to 'remake', so do it _only_ when
    # no previous project() command has been previously called.
    project(remake)
endif()

macro(include_here path) # paths
    include(${CMAKE_CURRENT_LIST_DIR}/${path})
endmacro()

include_here(core/output.cmake)
include_here(core/variables.cmake)
include_here(core/properties.cmake)
include_here(core/mods.cmake)
include_here(core/deps.cmake)

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

macro(dirname var path)
    get_filename_component(${var} ${path} PATH)
endmacro()

macro(add_compile_flags flag0) # ...
    set_property(DIRECTORY APPEND PROPERTY COMPILE_FLAGS ${flag0} ${ARGN})
endmacro()

set_global_and_local(REMAKE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set_global_and_local(HERE_BIN ${CMAKE_CURRENT_BINARY_DIR})

macro(set_target_vars name)
    set_global_and_local(T    ${name})
    set_global_and_local(HERE ${CMAKE_CURRENT_SOURCE_DIR})
    set_global_and_local(HERE_BIN ${CMAKE_CURRENT_BINARY_DIR})
endmacro()

macro(target name)
    project(${name})
    set_target_vars(${name})
    include_directories(${HERE_BIN} ${HERE})
endmacro()

macro(get_target_globals)
    get_global(T)
    get_global(HERE)
    get_global(HERE_BIN)
endmacro()

register_target_properties(
    SOURCES
    GENERATED
    WIN32_RC
    FILES
    DEPS
    FILENAME
    DEFS
    COMPILE_FLAGS
    INCLUDES
    FLAGS
    LIBS
    LIBS_OPTIMIZED
    LIBS_DEBUG
)

include_here(mods.cmake)

macro(pre_target target)

    set_target_vars(${target})

    load_target_properties(${target})
    mods_pre_target(${target})
    get_target_properties(${target})

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

    load_target_properties(${target})
    mods_post_target(${target})
    get_target_properties(${target})

    foreach(dep ${${target}_DEPS})
        run_dep(${target} ${dep})
    endforeach()

    if(${target}_FILENAME)
        set_property(TARGET ${target} PROPERTY OUTPUT_NAME ${${target}_FILENAME})
    endif()
    if(${target}_DEFS)
        set_property(TARGET ${target} APPEND PROPERTY COMPILE_DEFINITIONS ${${target}_DEFS})
    endif()
    if(${target}_COMPILE_FLAGS)
        set_property(TARGET ${target} APPEND PROPERTY COMPILE_FLAGS ${${target}_COMPILE_FLAGS})
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
