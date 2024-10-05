#
# The usual heavy lifting everybody hates about CMake.
# Contains all the functions to build packages, exe's, or tests.
# Already used iternally by maker.cmake.
# Just use `make_project` from the maker to save yourself the headache.
#

cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

## Private
function(__IntoBuildInterface__ __in_list__ __out_list__)
    set(result "")
    
    foreach(item ${__in_list__})
        list(APPEND result "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${item}>")
    endforeach(item)

    set(${__out_list__} "${result}" PARENT_SCOPE)
endfunction()
##



# builds an interface package
function(builder_BuildPackage)
    message("[ BUILDING PACKAGE ${package_namespace}::${package_name} ]")

    ## Library
    add_library(${package_name} INTERFACE ${package_sources})
    add_library(${package_namespace}::${package_name} ALIAS ${package_name})

    __IntoBuildInterface__("${package_includes}"    build_interface_package_includes)
    __IntoBuildInterface__("${package_lib_dirs}"    build_interface_package_lib_dirs)

    # checking whether combined correctly
    if(MAIN_PROJECT)
        message("'''''''''''''''''''''''''''''''")
        message("''\t\t${package_name}")
        message("'''''''''''''''''''''''''''''''")

        message("+ External include directories:")
        foreach(item ${build_interface_package_includes})
            message("+ \t-> ${item}")
        endforeach(item)
        
        message("+ External library directories:")
        foreach(item ${build_interface_package_lib_dirs})
            message("+ \t-> ${item}")
        endforeach(item)
    
        message("+ Export libraries:")
        foreach(item ${package_libs})
            message("+ \t-> ${item}")
        endforeach(item)

        message("'''''''''''''''''''''''''''''''")
    endif()
    #

    target_include_directories(${package_name}
        INTERFACE
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            ${build_interface_package_includes}
            $<INSTALL_INTERFACE:include>
    )

    target_link_directories(${package_name}
        INTERFACE
            ${build_interface_package_lib_dirs}
    )

    target_link_libraries(${package_name}
        INTERFACE
            ${package_libs}
    )

    target_compile_features(${package_name} INTERFACE cxx_std_20)
    
    # Configure #
    set(__package_folder__          ${package_name})
    set(__package_target__          ${package_name}-targets)
    set(__package_config__          ${package_name}-config.cmake)
    set(__package_config_version__  ${package_name}-config-version.cmake)

    configure_package_config_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/${__package_config__}.in
        ${CMAKE_CURRENT_BINARY_DIR}/${__package_config__}
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${__package_folder__}
    )

    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/${__package_config_version__}.in
        ${CMAKE_CURRENT_BINARY_DIR}/${__package_config_version__} @ONLY
    )
    # - #

    # Install #
    set(__lib_dir__     ${CMAKE_INSTALL_LIBDIR})
    set(__bin_dir__     ${CMAKE_CURRENT_BINARY_DIR})
    set(__include_dir__ ${CMAKE_INSTALL_INCLUDEDIR})

    install(
        TARGETS     ${package_name}
        EXPORT      ${__package_target__}
    )

    install(
        EXPORT      ${__package_target__}
        NAMESPACE   ${package_namespace}::
        DESTINATION ${__lib_dir__}/cmake/${package_name}
    )

    export(
        EXPORT      ${__package_target__}
        NAMESPACE   ${package_name}::
        FILE        ${__bin_dir__}/${__package_target__}.cmake
    )

    if(CMAKE_EXPORT_PACKAGE_REGISTRY)
        export(
            PACKAGE ${package_name}
        )
    endif()

    set(__config__          ${package_name}-config.cmake)
    set(__config_version__  ${package_name}-config-version.cmake)
    install(
        FILES       ${__bin_dir__}/${__config__}
                    ${__bin_dir__}/${__config_version__}
        DESTINATION ${__lib_dir__}/cmake/${package_folder}
    )
    
    file(GLOB_RECURSE __headers__ "include/*.hpp" "include/*.h")

    install(
        FILES       ${__headers__}
        DESTINATION ${__include_dir__}/${package_subfolder}/
    )
    # - #
endfunction()




# builds the main program
function(builder_BuildExe)
    message("[[ BUILDING EXE FOR ${exe_name} ]]")


    if(WIN32)
        # add_executable(${exe_name} WIN32 src/main.cpp ${exe_sources})
        add_executable(${exe_name}       src/main.cpp ${exe_sources})
    else()
        add_executable(${exe_name}       src/main.cpp ${exe_sources})
    endif()

    target_include_directories(${exe_name}
        PRIVATE
            include
            ${exe_includes}
    )

    target_link_libraries(${exe_name}
        PRIVATE
            ${exe_libs}
    )
    target_link_directories(${exe_name}
        PRIVATE
            ${exe_lib_dirs}
    )
    target_compile_features(${exe_name} PRIVATE cxx_std_20)

    if (MSVC)
        add_compile_options(/bigobj)
        target_compile_options(${exe_name} PRIVATE /bigobj)
    endif ()

endfunction()




# builds the test program
function(builder_BuildTest)
    message("[[ BUILDING TEST FOR ${test_name} ]]")
    # helpers_Fetch(googletest    "https://github.com/google/googletest.git"  main)
    
    if(WIN32)
        # add_executable(${test_name} WIN32 test/tests.cpp  ${test_sources})
        add_executable(${test_name} ${test_sources})
    else()
        add_executable(${test_name} ${test_sources})
    endif()

    target_include_directories(${test_name}
        PRIVATE
            include
            ${test_includes}
    )

    target_link_libraries(${test_name}
        PRIVATE
            ${test_libs}
            # gtest_main
    )
    target_link_directories(${test_name}
        PRIVATE
            ${test_lib_dirs}
    )
    target_compile_features(${test_name} PRIVATE cxx_std_20)

    if (MSVC)
        add_compile_options(/bigobj)
        target_compile_options(${test_name} PRIVATE /bigobj)
    endif ()

endfunction()
