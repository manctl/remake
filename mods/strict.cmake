register_target_properties(
    STRICT
)

if(APPLE OR CMAKE_COMPILER_IS_GNUC)
    set_global(REMAKE_STRICT_C_FLAGS   "-Wall -Wextra -Werror -ansi -std=c99   -pedantic -Wno-variadic-macros -Wno-long-long -Wno-unknown-pragmas")
endif()

if(APPLE OR CMAKE_COMPILER_IS_GNUCXX)
    set_global(REMAKE_STRICT_CXX_FLAGS "-Wall -Wextra -Werror -ansi -std=c++98 -pedantic -Wno-variadic-macros -Wno-long-long -Wno-unknown-pragmas")
endif()
