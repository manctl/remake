file(GLOB_RECURSE deps RELATIVE ${CMAKE_CURRENT_LIST_DIR}
    "${CMAKE_CURRENT_LIST_DIR}/deps/*.cmake"
)

foreach(dep ${deps})
    include_here(${dep})
endforeach()
