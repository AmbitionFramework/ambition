cmake_minimum_required (VERSION 2.8)
cmake_policy(VERSION 2.8)
project(Ambition)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake )
enable_testing()

find_package(Vala REQUIRED)
include(ValaVersion)
include(ValaPrecompile)
ensure_vala_version("0.18.0" MINIMUM)

IF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
	SET(CMAKE_INSTALL_PREFIX "/usr" CACHE PATH "install prefix" FORCE)
ENDIF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

IF(LIB_INSTALL_DIR)
ELSE()
SET(LIB_INSTALL_DIR lib)
ENDIF()

set (PKGNAME ambition)
set (PKGVERSION 0.1)
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")

IF(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	set (WIN32 1)
	set (FLAGS --define=WIN32)
ENDIF()

set (BINSOURCE ${CMAKE_BINARY_DIR}/src/libambition)
set (VAPIDIRS 
	--vapidir='${CMAKE_SOURCE_DIR}'
	--vapidir='${CMAKE_SOURCE_DIR}/vapi'
	--vapidir='${BINSOURCE}'
)
set (DEFAULT_VALA_OPTIONS
	${VAPIDIRS}
	--thread
	--enable-experimental
	--target-glib=2.32
	--debug
	-g
	${FLAGS}
)

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
SET( CMAKE_BUILD_TYPE Debug )
SET( CORE_DEPS_CFLAGS_ALL
	${CORE_DEPS_CFLAGS}
	${CORE_DEPS_CFLAGS_OTHER}
	-DGETTEXT_PACKAGE=ambition
)

add_subdirectory (share)
add_subdirectory (src/libambition)
add_subdirectory (src/ambition-bin)
add_subdirectory (test)

