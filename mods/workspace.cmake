function(begin_workspace)
    get_remake_globals()
    set(workspace_cpp ${HERE_BIN}/workspace.cpp)
    file(WRITE ${workspace_cpp} "// Dummy translation unit.\n")
    set_global(workspace_FILES ${workspace_cpp})
endfunction()

function(add_to_workspace first) # second ... last
    foreach(workspace_file ${first_workspace_file} ${ARGN})
        append_global(workspace_FILES ${CMAKE_CURRENT_SOURCE_DIR}/${workspace_file})
    endforeach()
endfunction()

function(end_workspace)
    get_global(workspace_FILES)
    set_property(SOURCE ${workspace_FILES} PROPERTY HEADER_FILE_ONLY TRUE)
    folderify_sources(${workspace_FILES})
    add_library(workspace ${workspace_FILES})
    set_property(TARGET workspace PROPERTY EXCLUDE_FROM_ALL TRUE)
    set_property(TARGET workspace PROPERTY FOLDER "[ReMake]")
endfunction()
