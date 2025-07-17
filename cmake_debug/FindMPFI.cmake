find_path(MPFI_INCLUDE_DIR
  NAMES mpfi.h
  PATHS ENV MPFI_DIR
        ${MPFI_DIR}/include
        /usr/include /usr/local/include
)

find_library(MPFI_LIBRARY
  NAMES mpfi
  PATHS ENV MPFI_DIR
        ${MPFI_DIR}/lib
        /usr/lib /usr/local/lib
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MPFI DEFAULT_MSG
  MPFI_LIBRARY MPFI_INCLUDE_DIR
)

if(MPFI_FOUND)
  set(MPFI_INCLUDE_DIRS ${MPFI_INCLUDE_DIR})
  set(MPFI_LIBRARIES ${MPFI_LIBRARY})
endif()
