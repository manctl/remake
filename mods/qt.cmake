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

macro(qt_moc var src0) # src1 ...
    if(QT5)
        qt5_wrap_cpp(${var} ${src0} ${ARGN})
    else()
        qt4_wrap_cpp(${var} ${src0} ${ARGN})
    endif()
endmacro()

macro(register_target_resources target KIND kind)
    set(${kind}_resources_h ${CMAKE_CURRENT_BINARY_DIR}/${target}-${kind}-resources.h)
    dir2code(${${kind}_resources_h} ${${target}_${KIND}})
    set(${kind}_resources_cpp ${CMAKE_CURRENT_BINARY_DIR}/${target}-${kind}-resources.cpp)
    dir2code(${${kind}_resources_cpp} ${${target}_${KIND}})
    set(moc_resources_cpp)
    qt_moc(moc_resources_cpp ${${kind}_resources_h})
    set(sources
        ${${kind}_resources_h}
        ${${kind}_resources_cpp}
        ${moc_resources_cpp}
    )
    append_target_property(${target} SOURCES   ${sources})
    append_target_property(${target} GENERATED ${sources})
endmacro(register_target_resources)

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
