#
# Boiler plate macros to keep CMakeLists.txt clean.
# Use these in your CMakeLists.txt at the end.
# Requires that you have set the necessary variables like `my_project`, `package_name`, .. .
# Just use the template from the example CMakeLists.txt.
#

# Sets everything up to make the project.
# Note: if you use conan make sure you call these lines BEFORE you call make_project:
#   include(${CMAKE_SOURCE_DIR}/path/to/conan/conanbuildinfo.cmake)
#   conan_basic_setup()
macro(make_project)
    include(helpers)
    include(builder)

    ## Is this the main project?
    set(MAIN_PROJECT OFF)
    if (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
        set(MAIN_PROJECT ON)
        message("[Main Project]")
    endif()
    ##

    ## Find Sources
    helpers_FindSources("src" sources EXCLUDE "main")
    helpers_FindSources("test" test_sources EXCLUDE "")
    list(APPEND sources ${external_sources})
    ##

    ## Library
    if(build_lib)
        set(package_name        ${my_library})
        set(package_folder      ${package_name})
        set(package_subfolder   ${my_library_subfolder})
        set(package_namespace   ${my_library_namespace})
        set(package_version     ${${PROJECT_NAME}_VERSION})
        
        set(package_includes    ${external_includes})
        set(package_sources     ${sources})
        set(package_libs        ${export_libs} ${CONAN_LIBS})
        set(package_lib_dirs    ${external_lib_dirs})

        builder_BuildPackage()

        # Let consumers know what package they are using
        if(NOT MAIN_PROJECT)
            message(">> Using package '${package_name}' version: '${package_version}' <<")
        endif()
    endif()
    ##

    if (MAIN_PROJECT)
        ## Main Program
        if (build_exe)
            set(exe_name        ${PROJECT_NAME}_main)
            set(exe_includes    ${external_includes})
            set(exe_sources     ${sources})
            set(exe_libs        ${external_libs} ${CONAN_LIBS})
            set(exe_lib_dirs    ${external_lib_dirs})

            builder_BuildExe()
        endif()

        ## Test Program
        if (build_test)
            set(test_name        ${PROJECT_NAME}_test)
            set(test_includes    ${external_includes})
            set(test_sources     ${sources} ${test_sources})
            set(test_libs        ${external_libs} ${CONAN_LIBS})
            set(test_lib_dirs    ${external_lib_dirs})

            builder_BuildTest()
        endif()
    endif()
endmacro()

macro(make_project_with_conan)
    include(${CMAKE_SOURCE_DIR}/support/conan/conanbuildinfo.cmake)
    conan_basic_setup()
    make_project()
endmacro()

