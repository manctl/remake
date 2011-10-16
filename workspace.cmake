macro(begin_workspace)
    set(workspace_cpp ${CMAKE_CURRENT_BINARY_DIR}/workspace.cpp)
    file(WRITE ${workspace_cpp} "// Dummy translation unit.\n")
    set_property(GLOBAL PROPERTY workspace_FILES ${workspace_cpp})
endmacro()

macro(add_to_workspace first_workspace_file) # ...
    foreach(workspace_file ${first_workspace_file} ${ARGN})
        set_property(GLOBAL APPEND PROPERTY workspace_FILES
            ${CMAKE_CURRENT_SOURCE_DIR}/${workspace_file}
        )
    endforeach()
endmacro()

macro(end_workspace)
    get_property(workspace_FILES GLOBAL PROPERTY workspace_FILES)
    add_library(workspace ${workspace_FILES})
    set_property(TARGET workspace PROPERTY EXCLUDE_FROM_ALL TRUE)
    set_property(SOURCE ${workspace_FILES} PROPERTY HEADER_FILE_ONLY TRUE)
endmacro()
