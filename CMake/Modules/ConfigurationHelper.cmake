function(check_external_cache_change PROJECT_NAME BINARY_DIR STAMP_DIR
         CACHE_ARGS_VAR)
  set(CACHE_ARGS "${${CACHE_ARGS_VAR}}")

  string(SHA1 CACHE_HASH "${CACHE_ARGS}")

  set(HASH_FILE "${STAMP_DIR}/${PROJECT_NAME}-config-hash.txt")

  if(NOT EXISTS "${HASH_FILE}")
    file(WRITE "${HASH_FILE}" "${CACHE_HASH}")
    file(REMOVE "${BINARY_DIR}/CMakeCache.txt")
  else()
    file(READ "${HASH_FILE}" OLD_HASH)
    if(NOT OLD_HASH STREQUAL CACHE_HASH)
      message(
        STATUS
          "[${PROJECT_NAME}] Detected CMAKE_CACHE_ARGS change, clearing cache..."
      )
      file(WRITE "${HASH_FILE}" "${CACHE_HASH}")
      file(REMOVE "${BINARY_DIR}/CMakeCache.txt")
    endif()
  endif()
endfunction()

function(write_module_list OUTPUT_FILE PROJECT_NAME VERSION_VAR MODULE_LIST_VAR)
  if(DEFINED ${VERSION_VAR})
    set(ver_str "${${VERSION_VAR}}")
  else()
    set(ver_str "UNKNOWN")
  endif()

  file(APPEND ${OUTPUT_FILE} "${PROJECT_NAME} Version: ${ver_str}\n")
  file(APPEND ${OUTPUT_FILE} "Used Modules:\n")

  foreach(mod IN LISTS ${MODULE_LIST_VAR})
    file(APPEND ${OUTPUT_FILE} "  - ${mod}\n")
  endforeach()

  file(APPEND ${OUTPUT_FILE} "\n")

  message(
    STATUS "Wrote ${PROJECT_NAME} module list and version to ${OUTPUT_FILE}")
endfunction()
