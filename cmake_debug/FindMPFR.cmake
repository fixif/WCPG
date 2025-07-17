find_path(MPFR_INCLUDE_DIR
  NAMES mpfr.h
  PATHS ENV MPFR_DIR
        ${MPFR_DIR}/include
        /usr/include /usr/local/include
)

find_library(MPFR_LIBRARY
  NAMES mpfr
  PATHS ENV MPFR_DIR
        ${MPFR_DIR}/lib
        /usr/lib /usr/local/lib
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MPFR DEFAULT_MSG
  MPFR_LIBRARY MPFR_INCLUDE_DIR
)

if(MPFR_FOUND)
  set(MPFR_INCLUDE_DIRS ${MPFR_INCLUDE_DIR})
  set(MPFR_LIBRARIES ${MPFR_LIBRARY})
endif()
