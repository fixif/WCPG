cmake_minimum_required(VERSION 3.28)
project(WCPG LANGUAGES C)

# Add custom modules path
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

set(CMAKE_IGNORE_PREFIX_PATH
    "${CMAKE_IGNORE_PREFIX_PATH}"
    "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr"
    "/Library/Developer/CommandLineTools/SDKs/MacOSX15.5.sdk/usr"
)

find_package(GMP REQUIRED)
find_package(MPFR REQUIRED)
find_package(MPFI REQUIRED)
find_package(LAPACK REQUIRED)

message(STATUS "Libaries: ${LAPACK_LIBRARIES}")

include_directories(${CMAKE_CURRENT_BINARY_DIR})

# === Source files ===
file(GLOB WCPG_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/WCPG/*.c")

add_library(wcpg STATIC ${WCPG_SOURCES})

target_include_directories(wcpg
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
        ${GMP_INCLUDE_DIRS}
        ${MPFR_INCLUDE_DIRS}
        ${MPFI_INCLUDE_DIRS}
        ${LAPACK_INCLUDE_DIRS}
)

target_link_libraries(wcpg
    PUBLIC
        ${GMP_LIBRARIES}
        ${MPFR_LIBRARIES}
        ${MPFI_LIBRARIES}
        ${LAPACK_LIBRARIES}
        m
)

# === Optional examples ===
option(BUILD_EXAMPLES "Build example programs" ON)
if(BUILD_EXAMPLES)
    file(GLOB EX_SOURCES "exampleProgram/*.c")
    foreach(file ${EX_SOURCES})
        get_filename_component(name ${file} NAME_WE)
        add_executable(${name} ${file})
        target_link_libraries(${name} PRIVATE wcpg)
    endforeach()
endif()

# === Installation ===
include(GNUInstallDirs)

install(TARGETS wcpg
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/wcpg
)

install(DIRECTORY include/wcpg/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/wcpg
    FILES_MATCHING PATTERN "*.h"
)
