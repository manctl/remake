remake_properties(
    UIC_UNITS
    UIC
    MOC_UNITS
    MOC
    JS
    QML
    GFX
    QRC
)

macro(target_add_qrc target qrc name) # file ...
    set(qrc_cpp ${HERE_BIN}/${name}-qrc.cpp)
    add_custom_command(OUTPUT ${qrc_cpp}
        COMMAND ${QT_RCC_EXECUTABLE}
        ARGS -name ${name} -o ${qrc_cpp} ${qrc}
        MAIN_DEPENDENCY ${qrc}
        DEPENDS ${ARGN}
        VERBATIM
    )
    target_append(${T} SOURCES   ${qrc_cpp})
    target_append(${T} GENERATED ${qrc_cpp})
endmacro()
