cmake_minimum_required (VERSION 2.8)
cmake_policy(VERSION 2.8)
project(Ambition)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake )
enable_testing()

find_package(Vala REQUIRED)
include(ValaVersion)
include(ValaPrecompile)
ensure_vala_version("0.16.0" MINIMUM)

IF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
	SET(CMAKE_INSTALL_PREFIX "/usr" CACHE PATH "install prefix" FORCE)
ENDIF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

IF(LIB_INSTALL_DIR)
ELSE()
SET(LIB_INSTALL_DIR lib)
ENDIF()

option( WITH_ALMANNA "Include Almanna Integration plugin (requires libalmanna)" ON )
option( WITH_SCGI "Include SCGI Engine plugin (requires libgscgi)" ON )
option( WITH_TEXTCAPTCHA "Include TextCaptcha plugin" ON )
option( WITH_COUCH "Include Couch plugin" ON )
option( WITH_TWITTER "Include TwitterBootstrap plugin" ON )

set (PKGNAME ambition)
set (PKGVERSION 0.1)
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")

SET( CORE_DEPS_PACKAGES
	glib-2.0>=2.26
	gee-1.0
	gio-2.0
	json-glib-1.0
	gmodule-2.0
    libsoup-2.4
)
find_package(PkgConfig)
pkg_check_modules(CORE_DEPS REQUIRED ${CORE_DEPS_PACKAGES})
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

if (WITH_TWITTER)
	add_subdirectory (src/optional/plugin-twitter-bootstrap)
endif (WITH_TWITTER)

if (WITH_COUCH)
	add_subdirectory (src/optional/plugin-couchdb)
endif (WITH_COUCH)

if (WITH_TEXTCAPTCHA)
	add_subdirectory (src/optional/textcaptcha)
endif (WITH_TEXTCAPTCHA)

if (WITH_SCGI)
	add_subdirectory (src/optional/engine-scgi)
endif (WITH_SCGI)

if (WITH_ALMANNA)
	add_subdirectory (src/optional/plugin-almanna)
endif (WITH_ALMANNA)
