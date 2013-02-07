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

macro(set_global var val)
    set_property(GLOBAL PROPERTY ${var} ${val})
endmacro()

macro(get_global var)
    get_property(${var} GLOBAL PROPERTY ${var})
endmacro()

macro(set_internal var val)
    set(${var} ${val} CACHE INTERNAL "")
endmacro()

macro(append_global var first) # second ... last
    get_global(${var})
    list(APPEND ${var} ${first} ${ARGN})
    set_global(${var} ${${var}})
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
    set(M64 ON)
else()
    set(M32 ON)
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

macro(add_compile_flags flag0) # ...
    set_property(DIRECTORY APPEND PROPERTY COMPILE_FLAGS ${flag0} ${ARGN})
endmacro()

macro(target target_)
    project(${target_})
    set(HERE_BIN ${CMAKE_CURRENT_BINARY_DIR})
    set(HERE     ${CMAKE_CURRENT_SOURCE_DIR})
    include_directories(${HERE_BIN} ${HERE})
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

macro(pre_target target)
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
    if(${target}_MOC)
        QT4_WRAP_CPP(${target}_MOC_SOURCES ${${target}_MOC})
        append(${target}_SOURCES ${${target}_MOC_SOURCES})
    endif()
    if(${target}_JS)
        set(js_qrc ${CMAKE_CURRENT_BINARY_DIR}/${target}-js.qrc)
        dir2code(${js_qrc} ${${target}_JS})
        append(${target}_QRC ${js_qrc})
        append(${target}_GENERATED ${js_qrc})
        append(${target}_FILES ${${target}_JS})
        register_target_files(${target} JS js)
    endif()
    if(${target}_QML)
        set(qmldir ${CMAKE_CURRENT_BINARY_DIR}/${target}-qmldir)
        dir2code(${qmldir} ${${target}_QML})
        set(qml_qrc ${CMAKE_CURRENT_BINARY_DIR}/${target}-qml.qrc)
        dir2code(${qml_qrc} ${${target}_QML} ${qmldir})
        append(${target}_QRC ${qml_qrc})
        append(${target}_GENERATED ${qml_qrc} ${qmldir})
        append(${target}_FILES ${${target}_QML} ${qmldir})
        register_target_files(${target} QML qml)
    endif()
    if(${target}_GFX)
        set(gfx_qrc ${CMAKE_CURRENT_BINARY_DIR}/${target}-gfx.qrc)
        dir2code(${gfx_qrc} ${${target}_GFX})
        append(${target}_QRC ${gfx_qrc})
        append(${target}_GENERATED ${gfx_qrc})
        append(${target}_FILES ${${target}_GFX})
        register_target_files(${target} GFX gfx)
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
    # FIXME: Get deps back.
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
            if(src_lang STREQUAL "C" AND DEFINED CBUILD_STRICT_C_FLAGS)
                set_property(SOURCE ${src} APPEND PROPERTY COMPILE_FLAGS ${CBUILD_STRICT_C_FLAGS})
            elseif(src_lang STREQUAL "CXX" AND DEFINED CBUILD_STRICT_CXX_FLAGS)
                set_property(SOURCE ${src} APPEND PROPERTY COMPILE_FLAGS ${CBUILD_STRICT_CXX_FLAGS})
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
endmacro()

macro(build_shared_library target)
    pre_target(${target})
    add_library(${target} SHARED
        ${${target}_SOURCES}
    )
    post_target(${target})
    link(${target})
    set_property(TARGET ${target} PROPERTY FOLDER "dlls")
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
