macro(target_add_qrc target qrc name) # file ...
    set(qrc_cpp ${CMAKE_CURRENT_BINARY_DIR}/${name}-qrc.cpp)
    add_custom_command(OUTPUT ${qrc_cpp}
        COMMAND ${QT_RCC_EXECUTABLE}
        ARGS -name ${name} -o ${qrc_cpp} ${qrc}
        MAIN_DEPENDENCY ${qrc}
        DEPENDS ${ARGN}
        VERBATIM
    )
    append(${target}_SOURCES   ${qrc_cpp})
    append(${target}_GENERATED ${qrc_cpp})
endmacro()
