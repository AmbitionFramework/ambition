cmake_minimum_required (VERSION 2.8)
cmake_policy(VERSION 2.8)
project(Skra)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake )
enable_testing()

find_package(Vala REQUIRED)
include(ValaVersion)
include(ValaPrecompile)
ensure_vala_version("0.18.0" MINIMUM)

IF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  SET(CMAKE_INSTALL_PREFIX "/usr" CACHE PATH "install prefix" FORCE)
ENDIF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

set (APPNAME Skra)
set (BINNAME Skra-bin)
set (PREFIX ${CMAKE_INSTALL_PREFIX})

INCLUDE(plugins/plugins.cmake)

SET( APP_DEPS_PACKAGES
    gee-0.8
    ambition-0.1
    log4vala-0.1
    ${APP_PLUGIN_PKGCONFIG}
)

SET( APP_VALA_PACKAGES
	${APP_DEPS_PACKAGES}
	${APP_PLUGIN_PACKAGES}
	posix
	markdown
)

find_package(PkgConfig)
pkg_check_modules(APP_DEPS REQUIRED ${APP_DEPS_PACKAGES})

execute_process(
	COMMAND mkdir -p "${CMAKE_SOURCE_DIR}/src/.generated" )
execute_process(
	COMMAND ambition build-actions ${APPNAME} "${CMAKE_SOURCE_DIR}/config" "${CMAKE_SOURCE_DIR}/src/.generated"
	OUTPUT_VARIABLE ACTION_RESULT )
IF( ACTION_RESULT MATCHES "Fatal Error" )
	message( FATAL_ERROR ${ACTION_RESULT} )
ENDIF()
execute_process( 
	COMMAND ambition template-compile ${APPNAME} "${CMAKE_SOURCE_DIR}/src/View/Template" "${CMAKE_SOURCE_DIR}/src/.generated"
	OUTPUT_VARIABLE TEMPLATE_FILES )
IF( TEMPLATE_FILES MATCHES "Fatal Error" )
	message( FATAL_ERROR ${TEMPLATE_FILES} )
ENDIF()
SET( TEMPLATE_FILE_LIST )
FOREACH ( NEXT_ITEM ${TEMPLATE_FILES} )
	STRING( REPLACE "${CMAKE_SOURCE_DIR}/src/" "" NEXT_ITEM ${NEXT_ITEM} )
	LIST( APPEND TEMPLATE_FILE_LIST "${NEXT_ITEM}" )
ENDFOREACH()

add_subdirectory (src)

get_directory_property( APP_VALA_PACKAGES    DIRECTORY src DEFINITION APP_VALA_PACKAGES )
get_directory_property( APP_PLUGIN_VAPI_LIST DIRECTORY src DEFINITION APP_PLUGIN_VAPI_LIST )
get_directory_property( APP_CFLAGS           DIRECTORY src DEFINITION APP_CFLAGS )
get_directory_property( APP_LIB_PATHS        DIRECTORY src DEFINITION APP_LIB_PATHS )
get_directory_property( APP_DEPS_LIBRARIES   DIRECTORY src DEFINITION APP_DEPS_LIBRARIES )
get_directory_property( APP_PLUGIN_PACKAGES  DIRECTORY src DEFINITION APP_PLUGIN_PACKAGES )
get_directory_property( APP_VALA_C           DIRECTORY src DEFINITION APP_VALA_C )
get_directory_property( APP_AM_VALA_FILES    DIRECTORY src DEFINITION APP_AM_VALA_FILES )

add_subdirectory (test)
