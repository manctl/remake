register_target_properties(
    UIC_UNITS
    UIC
    MOC_UNITS
    MOC
    JS
    QML
    GFX
    QRC
)

macro(register_target_files target KIND kind)
    set(${kind}_files_h ${CMAKE_CURRENT_BINARY_DIR}/${target}-${kind}-files.h)
    dir2code(${${kind}_files_h} ${${target}_${KIND}})
    set(${kind}_files_cpp ${CMAKE_CURRENT_BINARY_DIR}/${target}-${kind}-files.cpp)
    dir2code(${${kind}_files_cpp} ${${target}_${KIND}})
    append_target_property(${target} SOURCES
        ${${kind}_files_h}
        ${${kind}_files_cpp}
    )
    append_target_property(${target} GENERATED
        ${${kind}_files_h}
        ${${kind}_files_cpp}
    )
endmacro(register_target_files)

macro(target_add_qrc target qrc name) # file ...
    set(qrc_cpp ${HERE_BIN}/${name}-qrc.cpp)
    if(QT5)
        get_target_property(QT_RCC_EXECUTABLE Qt5::rcc LOCATION)
    endif()
    add_custom_command(OUTPUT ${qrc_cpp}
        COMMAND ${QT_RCC_EXECUTABLE}
        ARGS -name ${name} -o ${qrc_cpp} ${qrc}
        MAIN_DEPENDENCY ${qrc}
        DEPENDS ${ARGN}
        VERBATIM
    )
    append_target_property(${target} SOURCES   ${qrc_cpp})
    append_target_property(${target} GENERATED ${qrc_cpp})
endmacro()
