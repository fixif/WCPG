# FindLAPACK.cmake
#
# Priority: user -DLAPACK_ROOT=...  → pkg-config → default.
# Exposes:
#   LAPACK_FOUND
#   LAPACK_LIBRARIES
#   LAPACK_INCLUDE_DIRS
#   LAPACK_VERSION (if pkg-config provides it)
#   Target: LAPACK::LAPACK
#
# Link order (if present): lapacke, lapack, blas/openblas.

include(FindPackageHandleStandardArgs)
find_package(PkgConfig QUIET)

# User override
set(LAPACK_ROOT "" CACHE PATH "Root path to a LAPACK installation (w/ include/, lib/).")

# -----------------------
# Helper: append_unique()
# -----------------------
function(_lapack_append_unique out_var)
  foreach(_item IN LISTS ARGN)
    if (_item AND NOT _item STREQUAL "NOTFOUND")
      list(FIND ${out_var} "${_item}" _idx)
      if (_idx EQUAL -1)
        list(APPEND ${out_var} "${_item}")
      endif()
    endif()
  endforeach()
  set(${out_var} "${${out_var}}" PARENT_SCOPE)
endfunction()

# -----------------------
# Phase 1: User LAPACK_ROOT
# -----------------------
if (LAPACK_ROOT)
  find_path(LAPACK_INCLUDE_DIR
    NAMES lapacke.h clapack.h
    HINTS "${LAPACK_ROOT}/include"
    NO_DEFAULT_PATH
  )
  find_library(LAPACK_lapacke
    NAMES lapacke
    HINTS "${LAPACK_ROOT}/lib"
    NO_DEFAULT_PATH
  )
  find_library(LAPACK_lapack
    NAMES lapack
    HINTS "${LAPACK_ROOT}/lib"
    NO_DEFAULT_PATH
  )
  find_library(LAPACK_blas
    NAMES blas openblas
    HINTS "${LAPACK_ROOT}/lib"
    NO_DEFAULT_PATH
  )
endif()

# -----------------------
# Phase 2: pkg-config
# -----------------------
if (NOT LAPACK_lapack AND PkgConfig_FOUND)
  # Try several pkg names; first one that works wins.
  foreach(_cand lapack lapacke openblas blas)
    if (NOT PC_LAPACK_FOUND)
      pkg_check_modules(PC_LAPACK QUIET ${_cand})
    endif()
  endforeach()

  if (PC_LAPACK_FOUND)
    # Headers
    if (NOT LAPACK_INCLUDE_DIR)
      find_path(LAPACK_INCLUDE_DIR
        NAMES lapacke.h clapack.h
        HINTS ${PC_LAPACK_INCLUDE_DIRS}
        NO_DEFAULT_PATH  # trust pkg-config first; avoids Apple SDK
      )
    endif()

    # Libraries
    if (NOT LAPACK_lapacke)
      find_library(LAPACK_lapacke
        NAMES lapacke
        HINTS ${PC_LAPACK_LIBRARY_DIRS}
        NO_DEFAULT_PATH
      )
    endif()
    if (NOT LAPACK_lapack)
      find_library(LAPACK_lapack
        NAMES lapack
        HINTS ${PC_LAPACK_LIBRARY_DIRS}
        NO_DEFAULT_PATH
      )
    endif()
    if (NOT LAPACK_blas)
      find_library(LAPACK_blas
        NAMES blas openblas
        HINTS ${PC_LAPACK_LIBRARY_DIRS}
        NO_DEFAULT_PATH
      )
    endif()

    set(LAPACK_VERSION "${PC_LAPACK_VERSION}")
  endif()
endif()

# -----------------------
# Phase 3: final fallback (system search; may hit Apple SDK)
# -----------------------
if (NOT LAPACK_INCLUDE_DIR)
  find_path(LAPACK_INCLUDE_DIR NAMES lapacke.h clapack.h)
endif()

if (NOT LAPACK_lapacke)
  find_library(LAPACK_lapacke NAMES lapacke)
endif()

if (NOT LAPACK_lapack)
  find_library(LAPACK_lapack NAMES lapack)
endif()

if (NOT LAPACK_blas)
  find_library(LAPACK_blas NAMES blas openblas)
endif()

# -----------------------
# Compose result lists
# -----------------------
set(LAPACK_INCLUDE_DIRS "${LAPACK_INCLUDE_DIR}")

set(_lapack_libs "")
_lapack_append_unique(_lapack_libs "${LAPACK_lapacke}")
_lapack_append_unique(_lapack_libs "${LAPACK_lapack}")
_lapack_append_unique(_lapack_libs "${LAPACK_blas}")

set(LAPACK_LIBRARIES "${_lapack_libs}")

# -----------------------
# Handle standard args
# -----------------------
# Require at least a LAPACK core library.
find_package_handle_standard_args(LAPACK
  REQUIRED_VARS LAPACK_lapack LAPACK_INCLUDE_DIR
  VERSION_VAR LAPACK_VERSION
)

# -----------------------
# Imported target
# -----------------------
if (LAPACK_FOUND AND NOT TARGET LAPACK::LAPACK)
  add_library(LAPACK::LAPACK INTERFACE IMPORTED)
  if (LAPACK_INCLUDE_DIRS)
    set_target_properties(LAPACK::LAPACK PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${LAPACK_INCLUDE_DIRS}"
    )
  endif()
  if (LAPACK_LIBRARIES)
    set_target_properties(LAPACK::LAPACK PROPERTIES
      INTERFACE_LINK_LIBRARIES "${LAPACK_LIBRARIES}"
    )
  endif()
endif()

mark_as_advanced(
  LAPACK_ROOT
  LAPACK_INCLUDE_DIR
  LAPACK_lapacke
  LAPACK_lapack
  LAPACK_blas
)
