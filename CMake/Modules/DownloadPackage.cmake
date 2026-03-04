function(download_file_if_not_exist URL OUTPUT_PATH CHECK_MD5 MD5_HASH)
  find_program(CURL_EXE curl)
  if(NOT CURL_EXE)
    message(FATAL_ERROR "curl not found in PATH")
  endif()

  if(EXISTS ${OUTPUT_PATH})
    message(STATUS "File exists: ${OUTPUT_PATH}")
  else()
    message(STATUS "Downloading ${URL} to ${OUTPUT_PATH} ...")

    execute_process(
      COMMAND ${CURL_EXE} -L -f -x ${CUSTOM_HTTPS_PROXY} -o ${OUTPUT_PATH} ${URL}
      RESULT_VARIABLE CURL_RESULT
      OUTPUT_VARIABLE CURL_OUTPUT
      ERROR_VARIABLE CURL_ERROR
    )

    if(NOT CURL_RESULT EQUAL 0)
      message(
        FATAL_ERROR
        "Download failed, curl returned: ${CURL_RESULT}\n${CURL_ERROR}")
    endif()
  endif()

  if(${CHECK_MD5})
    file(MD5 ${OUTPUT_PATH} CALCULATED_MD5)

    if(NOT CALCULATED_MD5 STREQUAL ${MD5_HASH})
      message(
        FATAL_ERROR
        "MD5 checksum mismatch for ${OUTPUT_PATH}\nExpected: ${MD5_HASH}\nGot: ${CALCULATED_MD5}"
      )
    else()
      message(STATUS "MD5 checksum passed for ${OUTPUT_PATH}")
    endif()
  endif()
endfunction()
