macro(register_qt_dep dep)
    if(QT5)
        register_dep_alias(qt-${dep} qt5-${dep})
    else()
        register_dep_alias(qt-${dep} qt4-${dep})
    endif()
endmacro()

# Generic Qt Components (Qt4 & Qt5)

register_qt_dep(core        )
register_qt_dep(gui         )
register_qt_dep(multimedia  )
register_qt_dep(network     )
register_qt_dep(opengl      )
register_qt_dep(script      )
register_qt_dep(script-tools)
register_qt_dep(sql         )
register_qt_dep(svg         )
register_qt_dep(webkit      )
register_qt_dep(xml         )
register_qt_dep(xml-patterns)
register_qt_dep(declarative )
register_qt_dep(test        )
register_qt_dep(dbus        )
register_qt_dep(main-library)
register_qt_dep(qml-debug   )
register_qt_dep(concurrent  )
