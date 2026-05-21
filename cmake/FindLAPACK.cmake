# FindLAPACK.cmake
# Custom LAPACK finder that prioritizes:
#  1. User-specified LAPACK_ROOT
#  2. pkg-config hints
#  3. Homebrew paths on macOS
#  4. System paths (Linux fallback)
#
# Creates:
#  - LAPACK_FOUND
#  - LAPACK_LIBRARIES
#  - LAPACK_INCLUDE_DIRS
#  - LAPACK::LAPACK target

include(FindPackageHandleStandardArgs)
find_package(PkgConfig QUIET)

set(LAPACK_ROOT "" CACHE PATH "Root path to LAPACK installation (e.g., /opt/homebrew/opt/lapack)")

# Determine search restriction: macOS = no default path (avoid Apple SDK), Linux = normal search
if(APPLE)
  set(_lapack_no_default NO_DEFAULT_PATH)
else()
  set(_lapack_no_default "")
endif()

# Helper function: append unique
function(_lapack_append_unique out_var)
  foreach(item IN LISTS ARGN)
    if(item AND NOT item STREQUAL "NOTFOUND")
      list(FIND ${out_var} "${item}" idx)
      if(idx EQUAL -1)
        list(APPEND ${out_var} "${item}")
      endif()
    endif()
  endforeach()
  set(${out_var} "${${out_var}}" PARENT_SCOPE)
endfunction()

# -----------------------------------------------------
# 1. User override (highest priority)
# -----------------------------------------------------
if(LAPACK_ROOT)
  find_path(LAPACK_INCLUDE_DIR
    NAMES lapacke.h clapack.h
    HINTS "${LAPACK_ROOT}/include"
    NO_DEFAULT_PATH
  )
  find_library(LAPACK_lapack NAMES lapack HINTS "${LAPACK_ROOT}/lib" NO_DEFAULT_PATH)
  find_library(LAPACK_lapacke NAMES lapacke HINTS "${LAPACK_ROOT}/lib" NO_DEFAULT_PATH)
  find_library(LAPACK_blas NAMES blas openblas HINTS "${LAPACK_ROOT}/lib" NO_DEFAULT_PATH)
endif()

# -----------------------------------------------------
# 2. pkg-config fallback
# -----------------------------------------------------
if(NOT LAPACK_lapack AND PkgConfig_FOUND)
  pkg_check_modules(PC_LAPACK QUIET lapack lapacke openblas blas)
  if(PC_LAPACK_FOUND)
    if(NOT LAPACK_INCLUDE_DIR)
      find_path(LAPACK_INCLUDE_DIR
        NAMES lapacke.h clapack.h
        HINTS ${PC_LAPACK_INCLUDE_DIRS}
        ${_lapack_no_default}
      )
    endif()
    if(NOT LAPACK_lapack)
      find_library(LAPACK_lapack NAMES lapack HINTS ${PC_LAPACK_LIBRARY_DIRS} ${_lapack_no_default})
    endif()
    if(NOT LAPACK_lapacke)
      find_library(LAPACK_lapacke NAMES lapacke HINTS ${PC_LAPACK_LIBRARY_DIRS} ${_lapack_no_default})
    endif()
    if(NOT LAPACK_blas)
      find_library(LAPACK_blas NAMES blas openblas HINTS ${PC_LAPACK_LIBRARY_DIRS} ${_lapack_no_default})
    endif()
  endif()
endif()

# -----------------------------------------------------
# 3. Homebrew paths on macOS (explicit hint)
# -----------------------------------------------------
if(APPLE AND NOT LAPACK_lapack)
  find_path(LAPACK_INCLUDE_DIR
    NAMES lapacke.h clapack.h
    PATHS /opt/homebrew/include /usr/local/include /usr/local/opt/lapack/include
    ${_lapack_no_default}
  )
  find_library(LAPACK_lapack NAMES lapack
    PATHS /opt/homebrew/lib /usr/local/lib /usr/local/opt/lapack/lib
    ${_lapack_no_default}
  )
  find_library(LAPACK_lapacke NAMES lapacke
    PATHS /opt/homebrew/lib /usr/local/lib /usr/local/opt/lapack/lib
    ${_lapack_no_default}
  )
  find_library(LAPACK_blas NAMES blas openblas
    PATHS /opt/homebrew/lib /usr/local/lib /usr/local/opt/lapack/lib
    ${_lapack_no_default}
  )
endif()

# -----------------------------------------------------
# 4. Final fallback: System paths (Linux)
# -----------------------------------------------------
if(NOT APPLE)
  if(NOT LAPACK_INCLUDE_DIR)
    find_path(LAPACK_INCLUDE_DIR NAMES lapacke.h clapack.h)
  endif()
  if(NOT LAPACK_lapack)
    find_library(LAPACK_lapack NAMES lapack)
  endif()
  if(NOT LAPACK_lapacke)
    find_library(LAPACK_lapacke NAMES lapacke)
  endif()
  if(NOT LAPACK_blas)
    find_library(LAPACK_blas NAMES blas openblas)
  endif()
endif()

# Combine libraries
set(_lapack_libs "")
_lapack_append_unique(_lapack_libs "${LAPACK_lapacke}" "${LAPACK_lapack}" "${LAPACK_blas}")
set(LAPACK_LIBRARIES "${_lapack_libs}")
set(LAPACK_INCLUDE_DIRS "${LAPACK_INCLUDE_DIR}")

# Final check
find_package_handle_standard_args(LAPACK
  REQUIRED_VARS LAPACK_lapack LAPACK_INCLUDE_DIR
)

# Create imported target
if(LAPACK_FOUND AND NOT TARGET LAPACK::LAPACK)
  add_library(LAPACK::LAPACK INTERFACE IMPORTED)
  set_target_properties(LAPACK::LAPACK PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${LAPACK_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${LAPACK_LIBRARIES}"
  )
endif()
