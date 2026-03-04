function(copy_target_shared_libs target)
    get_target_property(target_type ${target} TYPE)
    if(NOT target_type STREQUAL "EXECUTABLE" AND NOT target_type STREQUAL "SHARED_LIBRARY")
        message(WARNING "Target ${target} is not executable or shared library, skipping copy")
        return()
    endif()

    get_target_property(libs ${target} INTERFACE_LINK_LIBRARIES)
    if(NOT libs)
        set(libs "")
    endif()

    get_target_property(output_dir ${target} RUNTIME_OUTPUT_DIRECTORY)
    if(NOT output_dir)
        set(output_dir $<TARGET_FILE_DIR:${target}>)
    endif()

    if(WIN32)
        set(LIB_EXT ".dll")
    elseif(APPLE)
        set(LIB_EXT ".dylib")
    else()
        set(LIB_EXT ".so")
    endif()

    foreach(lib ${libs})
        if(TARGET ${lib})
            get_target_property(lib_type ${lib} TYPE)
            if(lib_type STREQUAL "SHARED_LIBRARY")
                get_target_property(lib_location ${lib} LOCATION)
                add_custom_command(TARGET ${target} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    "${lib_location}"
                    "${output_dir}"
                    COMMENT "Copying shared library ${lib_location} to ${output_dir}"
                )
            endif()
        else()
            get_filename_component(lib_name ${lib} NAME)
            if(lib_name MATCHES "${LIB_EXT}$")
                if(EXISTS ${lib})
                    add_custom_command(TARGET ${target} POST_BUILD
                        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "${lib}"
                        "${output_dir}"
                        COMMENT "Copying external shared library ${lib} to ${output_dir}"
                    )
                endif()
            endif()
        endif()
    endforeach()
endfunction()
