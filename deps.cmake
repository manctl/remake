macro(package_dep name package libs_var)
    set(${name}_DEP "
        find_package(${package} REQUIRED)
        target_link_libraries(@TARGET@ %{${libs_var}})
    ")
endmacro()

package_dep(opengl OpenGL OPENGL_LIBRARIES)
package_dep(glut   GLUT   GLUT_LIBRARIES  )

#-------------------------------------------------------------------------------

macro(qt_dep name component)
    set(qt-${name}_DEP "
        find_package(Qt4 COMPONENTS ${component} REQUIRED)
        include(%{QT_USE_FILE})
        target_link_libraries(@TARGET@ %{QT_LIBRARIES})
    ")
endmacro()

qt_dep(core         QtCore       )
qt_dep(gui          QtGui        )
qt_dep(multimedia   QtMultimedia )
qt_dep(network      QtNetwork    )
qt_dep(opengl       QtOpenGL     )
qt_dep(openvg       QtOpenVG     )
qt_dep(script       QtScript     )
qt_dep(script-tools QtScriptTools)
qt_dep(sql          QtSql        )
qt_dep(svg          QtSvg        )
qt_dep(webkit       QtWebKit     )
qt_dep(xml          QtXml        )
qt_dep(xml-patterns QtXmlPatterns)
qt_dep(declarative  QtDeclarative)
qt_dep(phonon       Phonon       )
qt_dep(qt3-support  Qt3Support   )
qt_dep(designer     QtDesigner   )
qt_dep(ui-tools     QtUiTools    )
qt_dep(help         QtHelp       )
qt_dep(test         QtTest       )
qt_dep(ax-container QAxContainer )
qt_dep(ax-server    QAxServer    )
qt_dep(dbus         QtDBus       )

set(qt-qml-debug_DEP "
    find_package(Qt4 COMPONENTS QtDeclarative REQUIRED)
    include(%{QT_USE_FILE})
    if(QT_VERSION VERSION_LESS \"4.8.0\")
        include_directories(%{QT_BINARY_DIR}/../qtc-qmldbg/include)
    endif()
    foreach(config DEBUG RELWITHDEBINFO)
        set_property(TARGET @TARGET@ APPEND PROPERTY COMPILE_DEFINITIONS_%{config} QT_DECLARATIVE_DEBUG)
    endforeach()
")
