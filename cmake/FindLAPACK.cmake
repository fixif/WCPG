# Distributed under the FloPoCo License, see README.md for more information

#[=======================================================================[.rst:
FindLAPACK
-------

Finds the LAPACK library.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``LAPACK::LAPACK``
  The LAPACK library

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``LAPACK_FOUND``
  True if the system has the LAPACK library.
``LAPACK_VERSION``
  The version of the LAPACK library which was found.
``LAPACK_INCLUDE_DIRS``
  Include directories needed to use LAPACK.
``LAPACK_LIBRARIES``
  Libraries needed to link to LAPACK.

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``LAPACK_INCLUDE_DIR``
  The directory containing ``LAPACK.h``.
``LAPACK_LIBRARY``
  The path to the LAPACK library.

#]=======================================================================]

find_package(PkgConfig)
pkg_check_modules(PC_LAPACK QUIET LAPACK)

find_path(LAPACK_INCLUDE_DIR
    NAMES lapack.h
    PATHS ${LAPACK_ROOT_DIR}/include ${PC_LAPACK_INCLUDE_DIRS}
    DOC "Path of LAPACK.h, the include file for GNU LAPACK library"
)

find_library(LAPACK_LIBRARY
    NAMES lapack
    PATHS ${LAPACK_ROOT_DIR} ${PC_LAPACK_LIBRARY_DIRS}
    DOC "Directory of the LAPACK library"
)

find_library(LAPACKE_LIBRARY
    NAMES lapacke
    PATHS ${LAPACK_ROOT_DIR} ${PC_LAPACK_LIBRARY_DIRS}
    DOC "Directory of the LAPACKe library"
)

set(LAPACK_VERSION ${PC_LAPACK_VERSION})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    LAPACK
    FOUND_VAR LAPACK_FOUND
    REQUIRED_VARS
        LAPACK_LIBRARY
        LAPACK_INCLUDE_DIR
    VERSION_VAR LAPACK_VERSION
)

if (LAPACK_FOUND)
    set(LAPACK_LIBRARIES ${LAPACK_LIBRARY} ${LAPACKE_LIBRARY})
    set(LAPACK_INCLUDE_DIRS ${LAPACK_INCLUDE_DIR})
    set(LAPACK_DEFINITIONS ${PC_LAPACK_FLAGS_OTHER})
endif()

if (LAPACK_FOUND AND NOT TARGET LAPACK::LAPACK)
    add_library(LAPACK::LAPACK UNKNOWN IMPORTED)
    set_target_properties(LAPACK::LAPACK PROPERTIES
        IMPORTED_LOCATION "${LAPACK_LIBRARY}"
        INTERFACE_COMPILE_OPTIONS "${PC_LAPACK_FLAGS_OTHER}"
        INTERFACE_INCLUDE_DIRECTORIES "${LAPACK_INCLUDE_DIR}"
    )
endif()

mark_as_advanced(LAPACK_INCLUDE_DIR LAPACK_LIBRARY)
