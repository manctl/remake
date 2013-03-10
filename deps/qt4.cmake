function(register_qt4_dep name component)
    register_dep(qt4-${name} "
find_package(Qt4 COMPONENTS ${component} REQUIRED)
include(%{QT_USE_FILE})
target_link_libraries(@TARGET@ %{QT_LIBRARIES})
")
endfunction()

macro(register_qt4_only_dep dep)
    if(NOT QT5)
        register_dep_alias(qt-${dep} qt4-${dep})
    endif()
endmacro()

macro(register_qt4_only_alias alias dep)
    if(NOT QT5)
        register_dep_alias(qt-${alias} qt4-${dep})
    endif()
endmacro()

register_dep(qt4-main-library "
    find_package(Qt4 COMPONENTS QtCore REQUIRED)
    include (%{QT_USE_FILE})
    target_link_libraries(@TARGET@ %{QT_QTMAIN_LIBRARY})
")

register_dep(qt4-qml-debug "
find_package(Qt4 COMPONENTS QtDeclarative REQUIRED)
include(%{QT_USE_FILE})
if(QT_VERSION VERSION_LESS \"4.8.0\")
    include_directories(%{QT_BINARY_DIR}/../qtc-qmldbg/include)
endif()
foreach(config DEBUG RELWITHDEBINFO)
    set_property(TARGET @TARGET@ APPEND PROPERTY COMPILE_DEFINITIONS_%{config} QT_DECLARATIVE_DEBUG)
endforeach()
")

# All Qt4 Components
register_qt4_dep(core         QtCore       )
register_qt4_dep(gui          QtGui        )
register_qt4_dep(multimedia   QtMultimedia )
register_qt4_dep(network      QtNetwork    )
register_qt4_dep(opengl       QtOpenGL     )
register_qt4_dep(openvg       QtOpenVG     )
register_qt4_dep(script       QtScript     )
register_qt4_dep(script-tools QtScriptTools)
register_qt4_dep(sql          QtSql        )
register_qt4_dep(svg          QtSvg        )
register_qt4_dep(webkit       QtWebKit     )
register_qt4_dep(xml          QtXml        )
register_qt4_dep(xml-patterns QtXmlPatterns)
register_qt4_dep(declarative  QtDeclarative)
register_qt4_dep(phonon       Phonon       )
register_qt4_dep(qt3-support  Qt3Support   )
register_qt4_dep(designer     QtDesigner   )
register_qt4_dep(ui-tools     QtUiTools    )
register_qt4_dep(help         QtHelp       )
register_qt4_dep(test         QtTest       )
register_qt4_dep(ax-container QAxContainer )
register_qt4_dep(ax-server    QAxServer    )
register_qt4_dep(dbus         QtDBus       )

# Qt4 components abandoned in Qt5
register_qt4_only_dep(openvg)
register_qt4_only_dep(phonon)
register_qt4_only_dep(qt3-support)
register_qt4_only_dep(designer)
register_qt4_only_dep(ui-tools)
register_qt4_only_dep(help)
register_qt4_only_dep(ax-container)
register_qt4_only_dep(ax-server)

# Qt4 components extracted in Qt5
register_qt4_only_alias(concurrent core)