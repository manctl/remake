# See: http://qt-project.org/doc/qt-5.0/qtdoc/cmake-manual.html
# See: http://qt-project.org/doc/qt-5.0/qtdoc/modules.html

macro(register_qt5_dep name module)
    register_dep(qt5-${name} "
find_package(Qt5${module} REQUIRED)
qt5_use_modules(@TARGET@ ${module})
")
endmacro()

macro(register_qt5_only_dep dep)
    if(QT5)
        register_dep_alias(qt-${dep} qt5-${dep})
    endif()
endmacro()

register_dep(qt5-main-library "
find_package(Qt5Core REQUIRED)
target_link_libraries(@TARGET@ Qt5::WinMain)
"
)

register_dep(qt5-qml-debug "# Nothing to do.")

# All Qt5 Essentials
register_qt5_dep(core           Core         )
register_qt5_dep(gui            GUI          )
register_qt5_dep(multimedia     Multimedia   )
register_qt5_dep(network        Network      )
register_qt5_dep(qml            QML          )
register_qt5_dep(quick          Quick        )
register_qt5_dep(sql            SQL          )
register_qt5_dep(test           Test         )
register_qt5_dep(webkit         WebKit       )
register_qt5_dep(webkit-widgets WebKitWidgets)
register_qt5_dep(       widgets       Widgets)

# All Qt5 Add-ons
register_qt5_dep(ax           ActiveQt)
register_qt5_dep(concurrent   Concurrent)
register_qt5_dep(dbus         DBus)
register_qt5_dep(gfx          GraphicalEffects)
register_qt5_dep(img          ImageFormats)
register_qt5_dep(opengl       OpenGL)
register_qt5_dep(print        PrintSupport)
register_qt5_dep(declarative  Declarative)
register_qt5_dep(script       Script)
register_qt5_dep(script-tools ScriptTools)
register_qt5_dep(svg          Svg)
register_qt5_dep(xml          Xml)
register_qt5_dep(xml-patterns XmlPatterns)

# New Qt5 Essentials
register_qt5_only_dep(quick)
register_qt5_only_dep(qml)
register_qt5_only_dep(widgets)
register_qt5_only_dep(webkit-widgets)

# New Qt5 Add-ons
register_qt5_only_dep(ax)
register_qt5_only_dep(concurrent)
register_qt5_only_dep(gfx)
register_qt5_only_dep(img)
register_qt5_only_dep(print)
