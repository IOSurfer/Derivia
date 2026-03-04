# Ninja-MSVC-Toolchain.cmake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake/ThirdParty/FindVcvars)
message(STATUS "CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}")

set(CMAKE_GENERATOR_PLATFORM x64 CACHE STRING "Build architecture")

find_program(NINJA_EXE NAMES ninja ninja-build)
if (NINJA_EXE)
    set(CMAKE_MAKE_PROGRAM "${NINJA_EXE}" CACHE FILEPATH "Ninja executable" FORCE)
else()
    message(FATAL_ERROR "Ninja not found. Please install Ninja or add it to PATH.")
endif()

# Invoke VS vcvars64.bat
if(NOT DEFINED ENV{VSCMD_ARG_TGT_ARCH})
    # Detect vcvars with FindVcvars.cmake 
    find_package(Vcvars REQUIRED)

    message(STATUS "Using vcvars script: ${Vcvars_BATCH_FILE}")
    message(STATUS "wrapper script generated in: ${Vcvars_WRAPPER_BATCH_FILE}")

    if(EXISTS "${Vcvars_BATCH_FILE}")
        execute_process(
            COMMAND cmd.exe /c "\"${Vcvars_BATCH_FILE}\" && set"
            OUTPUT_VARIABLE _env_out
            ERROR_VARIABLE _env_err
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        foreach(line IN LISTS _env_out)
            string(FIND "${line}" "=" eq_pos)
            if(NOT eq_pos EQUAL -1)
                string(SUBSTRING "${line}" 0 ${eq_pos} var)
                math(EXPR val_pos "${eq_pos}+1")
                string(SUBSTRING "${line}" ${val_pos} -1 value)
                set(ENV{${var}} "${value}")
            endif()
        endforeach()
    else()
        message(FATAL_ERROR "vcvars64.bat not found at ${_VCVARS}")
    endif()
endif()

find_program(MSVC_C_COMPILER cl)
find_program(MSVC_LINKER link)

if (NOT MSVC_C_COMPILER)
    message(FATAL_ERROR "MSVC cl.exe not found in PATH after vcvars64.bat")
endif()

set(CMAKE_C_COMPILER   "${MSVC_C_COMPILER}" CACHE FILEPATH "C Compiler" FORCE)
set(CMAKE_CXX_COMPILER "${MSVC_C_COMPILER}" CACHE FILEPATH "C++ Compiler" FORCE)
set(CMAKE_LINKER       "${MSVC_LINKER}" CACHE FILEPATH "Linker" FORCE)

set(CMAKE_NINJA_FORCE_RESPONSE_FILE ON CACHE BOOL "Use response file")
set(CMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS ON CACHE BOOL "Use response file")
set(CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS ON CACHE BOOL "Use response file")
set(CMAKE_C_USE_RESPONSE_FILE_FOR_INCLUDES ON CACHE BOOL "Use response file")
set(CMAKE_CXX_USE_RESPONSE_FILE_FOR_INCLUDES ON CACHE BOOL "Use response file")
set(CMAKE_C_USE_RESPONSE_FILE_FOR_LIBRARIES ON CACHE BOOL "Use response file")
set(CMAKE_CXX_USE_RESPONSE_FILE_FOR_LIBRARIES ON CACHE BOOL "Use response file")
set(CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS ON CACHE BOOL "Use response file")
set(CMAKE_CXX_RESPONSE_FILE_LINK_FLAG "@" CACHE STRING "Response file link flag")
set(CMAKE_C_RESPONSE_FILE_LINK_FLAG "@" CACHE STRING "Response file link flag")
