find_path(LAPACK_INCLUDE_DIR
  NAMES lapacke.h
  PATHS ENV LAPACK_DIR
        ${LAPACK_DIR}/include
        /usr/include /usr/local/include
)

find_library(LAPACK_LIBRARY
  NAMES lapack
  PATHS ENV LAPACK_DIR
        ${LAPACK_DIR}/lib
        /usr/lib /usr/local/lib
)

find_library(LAPACKE_LIBRARY
  NAMES lapacke
  PATHS ENV LAPACK_DIR
        ${LAPACK_DIR}/lib
        /usr/lib /usr/local/lib
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LAPACK DEFAULT_MSG
  LAPACK_LIBRARY LAPACK_INCLUDE_DIR
)

if(LAPACK_FOUND)
  set(LAPACK_INCLUDE_DIRS ${LAPACK_INCLUDE_DIR})
  set(LAPACK_LIBRARIES ${LAPACK_LIBRARY} ${LAPACKE_LIBRARY})
endif()
