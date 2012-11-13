function(register_dep dep code)
    set_global(${dep}_DEP "${code}")
endfunction()

function(run_dep target dep)
    get_global(${dep}_DEP)
    if(NOT ${dep}_DEP)
        message(SEND_ERROR "Missing dependency: ${dep}")
    else()
        set(TARGET ${target})
        configure_inline(${target}-${dep}-dep ${${dep}_DEP})
    endif()
endfunction()

function(register_library_dep lib)
    register_dep(${lib} "
include_directories(
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)
target_link_libraries(@TARGET@ ${lib})
")
endfunction()

function(register_package_dep name package libs_var)
    register_dep(${name} "
find_package(${package} REQUIRED)
target_link_libraries(@TARGET@ %{${libs_var}})
")
endfunction()

#-------------------------------------------------------------------------------

function(register_qt_dep name component)
    register_dep(qt-${name} "
find_package(Qt4 COMPONENTS ${component} REQUIRED)
include(%{QT_USE_FILE})
target_link_libraries(@TARGET@ %{QT_LIBRARIES})
")
endfunction()

register_qt_dep(core         QtCore       )
register_qt_dep(gui          QtGui        )
register_qt_dep(multimedia   QtMultimedia )
register_qt_dep(network      QtNetwork    )
register_qt_dep(opengl       QtOpenGL     )
register_qt_dep(openvg       QtOpenVG     )
register_qt_dep(script       QtScript     )
register_qt_dep(script-tools QtScriptTools)
register_qt_dep(sql          QtSql        )
register_qt_dep(svg          QtSvg        )
register_qt_dep(webkit       QtWebKit     )
register_qt_dep(xml          QtXml        )
register_qt_dep(xml-patterns QtXmlPatterns)
register_qt_dep(declarative  QtDeclarative)
register_qt_dep(phonon       Phonon       )
register_qt_dep(qt3-support  Qt3Support   )
register_qt_dep(designer     QtDesigner   )
register_qt_dep(ui-tools     QtUiTools    )
register_qt_dep(help         QtHelp       )
register_qt_dep(test         QtTest       )
register_qt_dep(ax-container QAxContainer )
register_qt_dep(ax-server    QAxServer    )
register_qt_dep(dbus         QtDBus       )

register_dep(qt-main-library "
    find_package(Qt4 COMPONENTS QtCore REQUIRED)
    include (%{QT_USE_FILE})
    target_link_libraries(@TARGET@ %{QT_QTMAIN_LIBRARY})
")

register_dep(qt-qml-debug "
find_package(Qt4 COMPONENTS QtDeclarative REQUIRED)
include(%{QT_USE_FILE})
if(QT_VERSION VERSION_LESS \"4.8.0\")
    include_directories(%{QT_BINARY_DIR}/../qtc-qmldbg/include)
endif()
foreach(config DEBUG RELWITHDEBINFO)
    set_property(TARGET @TARGET@ APPEND PROPERTY COMPILE_DEFINITIONS_%{config} QT_DECLARATIVE_DEBUG)
endforeach()
")

#-------------------------------------------------------------------------------

register_package_dep(opengl OpenGL OPENGL_LIBRARIES)
register_package_dep(glut   GLUT   GLUT_LIBRARIES  )
