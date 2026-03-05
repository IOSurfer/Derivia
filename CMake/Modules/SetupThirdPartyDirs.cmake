function(setup_third_party_dirs)

  set(THIRD_PARTY_ROOT
    "${CMAKE_BINARY_DIR}/ThirdParty"
    CACHE PATH "Root directory for third-party dependencies")

  set(THIRD_PARTY_DOWNLOAD_DIR "${THIRD_PARTY_ROOT}/Downloads" CACHE PATH "")

  foreach(dir
      ${THIRD_PARTY_ROOT}
      ${THIRD_PARTY_DOWNLOAD_DIR})
    file(MAKE_DIRECTORY ${dir})
  endforeach()

endfunction()