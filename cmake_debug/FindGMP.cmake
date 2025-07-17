find_path(GMP_INCLUDE_DIR
  NAMES gmp.h
  PATHS ENV GMP_DIR
        ${GMP_DIR}/include
        /usr/include /usr/local/include
)

find_library(GMP_LIBRARY
  NAMES gmp
  PATHS ENV GMP_DIR
        ${GMP_DIR}/lib
        /usr/lib /usr/local/lib
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GMP DEFAULT_MSG
  GMP_LIBRARY GMP_INCLUDE_DIR
)

if(GMP_FOUND)
  set(GMP_INCLUDE_DIRS ${GMP_INCLUDE_DIR})
  set(GMP_LIBRARIES ${GMP_LIBRARY})
endif()
