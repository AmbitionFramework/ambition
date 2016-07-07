cmake_minimum_required (VERSION 2.8)
cmake_policy(VERSION 2.8)
project(Ambition)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake )
enable_testing()

include(FindVala)
include(ValaHelper)
include(OSFlags)
include(AddCompilerFlags)
ensure_vala_version("0.18.0" MINIMUM)

global_add_compiler_flags(-Wno-incompatible-pointer-types)

SET( CMAKE_BUILD_TYPE Debug)

IF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
	SET(TEMP_PREFIX "/usr")
	IF(${OS_FBSD} EQUAL 1)
		SET(TEMP_PREFIX "/usr/local")
	ENDIF()
	SET(CMAKE_INSTALL_PREFIX ${TEMP_PREFIX} CACHE PATH "install prefix" FORCE)
ENDIF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

IF(LIB_INSTALL_DIR)
ELSE()
	SET(LIB_INSTALL_DIR lib)
ENDIF()

IF(PKGCONFIG_INSTALL_DIR)
ELSE()
	execute_process(COMMAND pkg-config --variable=pc_path pkg-config OUTPUT_VARIABLE PKGCONFIG_INSTALL_DIR_RAW)
	STRING(REGEX REPLACE ":.*" "" PKGCONFIG_INSTALL_DIR ${PKGCONFIG_INSTALL_DIR_RAW})
ENDIF()

SET( PKGNAME ambition)
SET( PKGVERSION 0.1)
SET( PREFIX ${CMAKE_INSTALL_PREFIX})
SET( DOLLAR "$")

SET( BINSOURCE ${CMAKE_BINARY_DIR}/src/libambition)
SET( VAPIDIRS 
	--vapidir='${CMAKE_SOURCE_DIR}'
	--vapidir='${CMAKE_SOURCE_DIR}/vapi'
	--vapidir='${BINSOURCE}'
)
SET( DEFAULT_VALA_OPTIONS
	${VAPIDIRS}
	--thread
	--enable-experimental
	--target-glib=2.32
	--debug
	-g
)
IF(${CMAKE_BUILD_TYPE} EQUAL "Debug")
	SET( DEFAULT_VALA_OPTIONS
		${DEFAULT_VALA_OPTIONS}
		--debug
		-g
	)
ENDIF()

SET( CORE_DEPS_PACKAGES
	glib-2.0
	gee-0.8
	gio-2.0
	json-glib-1.0
	gmodule-2.0
	libsoup-2.4
	log4vala-0.1
)
find_package(PkgConfig)
pkg_check_modules(CORE_DEPS REQUIRED ${CORE_DEPS_PACKAGES} glib-2.0>=2.32)
SET( CORE_DEPS_CFLAGS_ALL
	${CORE_DEPS_CFLAGS}
	${CORE_DEPS_CFLAGS_OTHER}
	-DGETTEXT_PACKAGE=ambition
)

add_subdirectory (share)
add_subdirectory (src/libambition)
add_subdirectory (src/ambition-bin)
add_subdirectory (test)

message( STATUS "----------------------------------------------------------------" )
message( STATUS "        OS: " ${FOUND_OS} )
message( STATUS "      Vala: " ${VALA_VERSION} )
message( STATUS "    Prefix: " ${PREFIX} )
message( STATUS " Pkgconfig: " ${PKGCONFIG_INSTALL_DIR} )
message( STATUS "Build type: " ${CMAKE_BUILD_TYPE} )
message( STATUS "----------------------------------------------------------------" )
