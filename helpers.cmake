#
# Cool functions to reduce boiler plate.
#


cmake_minimum_required(VERSION 3.10 FATAL_ERROR)


set(EMPTY_PLACEHOLDER "<EMPTY>")


set(DOWNLOAD_EXTRACT_TIMESTAMP ON)
if(${CMAKE_VERSION} VERSION_GREATER "3.24")
    cmake_policy(SET CMP0135 NEW)
endif()





# takes a variable and places a placeholder in it if it is empty
function(helpers_NotEmpty __out_var__)
    if("${${__out_var__}}" STREQUAL "")
        set(${__out_var__} ${EMPTY_PLACEHOLDER} PARENT_SCOPE)
    endif()
endfunction()

# checks if a variable is empty
function(helpers_IsEmpty __var__ __result__)
    if("${${__var__}}" STREQUAL "" OR "${${__var__}}" STREQUAL "${EMPTY_PLACEHOLDER}")
        set(${__result__} ON PARENT_SCOPE)
    else()
        set(${__result__} OFF PARENT_SCOPE)
    endif()
endfunction()




# checks arguments passed to a function
function(__CHECK_ARGS__ __function__)
    set(i 0)
    foreach(argv ${ARGN})
        if(${i} STREQUAL 0) # skip function name
            math(EXPR i "${i} + 1" )
            continue()
        endif()
        
        helpers_IsEmpty("${argv}" is_empty)
        if(is_empty)
            message("${__function__}: Parameter ${i}: ${argv} is empty!")
        endif()

        math(EXPR i "${i} + 1" )
    endforeach()
endfunction()




# fetches git repos with tag
include(FetchContent)
function(helpers_Fetch __name__ __url__ __tag__)
    FetchContent_Declare(${__name__}
        GIT_REPOSITORY  ${__url__}
        GIT_TAG         ${__tag__}
    )
    FetchContent_MakeAvailable(${__name__})
endfunction()

# fetches git repos direct release url
function(helpers_FetchUrl __name__ __url__)
    FetchContent_Declare(${__name__}
        URL             ${__url__}
    )
    FetchContent_MakeAvailable(${__name__})
endfunction()




# sets useful meta data
function(helpers_SetMeta)
    enable_language(CXX)
    set(CMAKE_DISABLE_SOURCE_CHANGES    ON)
    set(CMAKE_DISABLE_IN_SOURCE_BUILD   ON)
    set(CMAKE_BUILD_TYPE_INIT           "RelWithDebInfo")
    set(CMAKE_CONFIGURATION_TYPES       "Release;RelWithDebInfo" CACHE STRING "" FORCE)
    set(CMAKE_CXX_STANDARD              20)
    set(DOWNLOAD_EXTRACT_TIMESTAMP      ON)  # unsure if should set to off or on
    set(FETCHCONTENT_QUIET              OFF)         # wanna see what fetch content does

    include(GNUInstallDirs)
    include(CMakePackageConfigHelpers)
    
    if(${CMAKE_VERSION} VERSION_GREATER "3.24")
        cmake_policy(SET CMP0135 NEW)
    endif()
    
    if(NOT APPLE)
        set(CMAKE_INSTALL_RPATH $ORIGIN)
    endif()
endfunction()




# wraps items into $<BUILD_INTERFACE:..>
function(helpers_IntoBuildInterface __in_list__ __out_list__)
    set(result "")
    
    foreach(item ${__in_list__})
        # message("ITEM?? ${item}")
        list(APPEND result "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${item}>")
    endforeach(item)

    set(${__out_list__} "${result}" PARENT_SCOPE)
endfunction()




# prints a list
function(helpers_PrintList __list__)
    set(__prefix__ ${ARGV1})

    foreach(item ${__list__})
        message("${__prefix__}${item}")
    endforeach(item)
endfunction()





# finds all sources in the given directory that are not the excluded one
function(helpers_FindSources __folder__ __out_sources__ __exclude_keyword__ __exclude__)
    file(GLOB_RECURSE __sources__ "${__folder__}/*.cc" "${__folder__}/*.cpp" "${__folder__}/*.c" "${__folder__}/*.cxx")
    foreach(__item__ ${__sources__})
        if((${__item__} MATCHES "${__folder__}/${__exclude__}.cpp") OR (${__item__} MATCHES "${__folder__}/${__exclude__}.c"))
            list(REMOVE_ITEM __sources__ ${__item__})
        endif()
    endforeach()

    set(${__out_sources__} "${__sources__}" PARENT_SCOPE)
endfunction()




# installs an interface library
function(helpers_InstallInterface __name__ __folder__ __subfolder__)
    set(__lib_dir__     ${CMAKE_INSTALL_LIBDIR})
    set(__bin_dir__     ${CMAKE_CURRENT_BINARY_DIR})
    set(__include_dir__ ${CMAKE_INSTALL_INCLUDEDIR})

    set(__targets__ ${__name__}-targets)
    install(
        TARGETS     ${__name__}
        EXPORT      ${__targets__}
    )

    install(
        EXPORT      ${__targets__}
        NAMESPACE   ${__name__}::
        DESTINATION ${__lib_dir__}/cmake/${__name__}
    )

    export(
        EXPORT      ${__targets__}
        NAMESPACE   ${__name__}::
        FILE        ${__bin_dir__}/${__targets__}.cmake
    )

    if(CMAKE_EXPORT_PACKAGE_REGISTRY)
        export(
            PACKAGE ${__name__}
        )
    endif()

    set(__configure__ NOT(__folder__ STREQUAL ""))
    if(__configure__)    
        set(__config__          ${__name__}-config.cmake)
        set(__config_version__  ${__name__}-config-version.cmake)
        install(
            FILES       ${__bin_dir__}/${__config__}
                        ${__bin_dir__}/${__config_version__}
            DESTINATION ${__lib_dir__}/cmake/${__folder__}
        )
    endif()
    

    file(GLOB_RECURSE __headers__ "include/*.hpp" "include/*.h")

    if(__subfolder__ STREQUAL "")
        install(
            FILES       ${__headers__}
            DESTINATION ${__include_dir__}/
        )
    else()
        install(
            FILES       ${__headers__}
            DESTINATION ${__include_dir__}/${__subfolder__}/
        )
    endif()
endfunction()




# installs an interface library with no config
function(helpers_InstallInterface_NoConfig __name__)
    helpers_InstallInterface(${__name__} "" "")
endfunction()
