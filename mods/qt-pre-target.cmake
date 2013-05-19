if(${T}_JS)
    set(js_qrc ${HERE_BIN}/${T}-js.qrc)
    dir2code(${js_qrc} ${${T}_JS})
    target_add_qrc(${T} ${js_qrc} ${T}-js ${${T}_JS})
    append_target_property(${T} GENERATED ${js_qrc})
    append_target_property(${T} FILES ${${T}_JS})
    register_target_files(${T} JS js)
endif()

if(${T}_QML)
    set(qmldir ${HERE_BIN}/${T}-qmldir)
    set(qml_qrc ${HERE_BIN}/${T}-qml.qrc)
    dir2code(${qmldir} ${${T}_QML})
    dir2code(${qml_qrc} ${${T}_QML} ${qmldir})
    append_target_property(${T} GENERATED ${qml_qrc} ${qmldir})
    target_add_qrc(${T} ${qml_qrc} ${T}-qml ${${T}_QML})
    append_target_property(${T} FILES ${${T}_QML} ${qmldir})
    register_target_files(${T} QML qml)
endif()

if(${T}_GFX)
    set(gfx_qrc ${HERE_BIN}/${T}-gfx.qrc)
    dir2code(${gfx_qrc} ${${T}_GFX})
    target_add_qrc(${T} ${gfx_qrc} ${T}-gfx ${${T}_GFX})
    append_target_property(${T} GENERATED ${gfx_qrc})
    append_target_property(${T} FILES ${${T}_GFX})
    register_target_files(${T} GFX gfx)
endif()

if(${T}_QRC)
    if(QT5)
        qt5_add_resources(${T}_QRC_SOURCES ${${T}_QRC})
    else()
        qt4_add_resources(${T}_QRC_SOURCES ${${T}_QRC})
    endif()
    append_target_property(${T} SOURCES ${${T}_QRC} ${${T}_QRC_SOURCES})
endif()

if(${T}_UIC_UNITS)
    foreach(unit ${${T}_UIC_UNITS})
        append_target_property(${T} UIC ${unit}.ui)
        append_target_property(${T} MOC ${unit}.h)
        append_target_property(${T} SOURCES
            ${unit}.cpp
            ${unit}.h
        )
    endforeach()
endif()

if(${T}_UIC)
    if(QT5)
        qt5_wrap_ui(${T}_UIC_SOURCES ${${T}_UIC})
    else()
        qt4_wrap_ui(${T}_UIC_SOURCES ${${T}_UIC})
    endif()
    append_target_property(${T} SOURCES ${${T}_UIC} ${${T}_UIC_SOURCES})
endif()

if(${T}_MOC_UNITS)
    foreach(unit ${${T}_MOC_UNITS})
        append_target_property(${T} MOC ${unit}.h)
        append_target_property(${T} SOURCES
            ${unit}.cpp
            ${unit}.h
        )
    endforeach()
endif()

if(${T}_MOC)
    qt_moc(${T}_MOC_SOURCES ${${T}_MOC})
    append_target_property(${T} SOURCES ${${T}_MOC_SOURCES})
    debug("append_target_property(${T} SOURCES ${${T}_MOC_SOURCES})")
endif()
