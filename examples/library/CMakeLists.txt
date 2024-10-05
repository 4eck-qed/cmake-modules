cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

#############################################
##              EDIT HERE                  ##
#############################################
set(my_project              my_library)     # this project (for executable)
set(my_version              "1.0.0")
set(my_library              library)        # this library (for usage in other projects)
set(my_library_namespace    my)             # change if your project belongs to another namespace - e.g. setting my_namepace = other -> other::my_library
set(my_library_subfolder    ${my_library})  # headers will be exported into here - e.g: #include <my_library_subfolder/example.h>
set(build_exe               OFF)            # if this project has an executable - ensure this exists: src/main.cpp
set(build_lib               ON)             # turn off if this shall not be used as library
set(build_test              OFF)            # if you want to build tests - ensure this exists: test/tests.cpp

# add git repositories to fetch here
# helpers_Fetch(example "https://github.com/an/example.git" example_branch)
# helpers_Fetch(bz2           "https://github.com/LuaDist/bzip2.git"      master)
helpers_Fetch(fmt           "https://github.com/fmtlib/fmt.git"         master)

set(external_includes
    # add external include paths here
    # an/example/include
    # external/third_party_lib/include
)

file(GLOB_RECURSE external_sources
    # add external source paths here
    # "an/example/src/*.c*"
)

set(export_libs
    # add libraries that shall be exported along with library here
    # if not configured for export, you have to configure it yourself
    # note: if it has no targets exported, this works: install_interface(anexample ${CMAKE_INSTALL_LIBDIR} ${CMAKE_CURRENT_BINARY_DIR})
    # $ENV{Boost_LIBRARIES}
)


set(external_libs
    # add external libraries to link here
    # an::example
    ${export_libs}
    fmt::fmt
)

set(external_lib_dirs
    # add external library files to link here
    # an/example/lib
)
#############################################
##                 END                     ##
#############################################

project(${my_project}
    VERSION     ${my_version}
    LANGUAGES   CXX
)

# Where are the cmake modules
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/support/cmake/modules")
include(maker)

make_project()
