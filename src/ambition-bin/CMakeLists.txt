set (BINNAME ambition)
set (PKGNAME ambition)
set (PKGVERSION 0.1)

FIND_PATH(READLINE_INCLUDE_DIR readline/readline.h)
FIND_LIBRARY(READLINE_LIBRARY NAMES readline)

IF (READLINE_INCLUDE_DIR)
	MESSAGE(STATUS "found readline.h: ${READLINE_INCLUDE_DIR}")
ELSE (READLINE_INCLUDE_DIR)
	MESSAGE(FATAL_ERROR "Missing readline.h")
ENDIF (READLINE_INCLUDE_DIR)

IF (READLINE_LIBRARY)
	MESSAGE(STATUS "found libreadline: ${READLINE_LIBRARY}")
ELSE (READLINE_LIBRARY)
	MESSAGE(FATAL_ERROR "Missing libreadline")
ENDIF (READLINE_LIBRARY)

SET( AB_VALA_PACKAGES
	${CORE_DEPS_PACKAGES}
	readline
	posix
)

vala_precompile(AB_VALA_C
	Binary.vala
	Shell.vala
PACKAGES
	${AB_VALA_PACKAGES}
	${PKGNAME}-${PKGVERSION}
OPTIONS
	--thread
	--vapidir ../libambition
	--enable-experimental
	-g)

set(AB_CFLAGS
	${CORE_DEPS_CFLAGS_ALL}
	-I../libambition
	-I${READLINE_INCLUDE_DIR}
	-w
)
set(AB_LIB_PATHS
	${CORE_DEPS_LIBRARY_DIRS}
	${CMAKE_BINARY_DIR}/libambition
)
add_definitions(${AB_CFLAGS})

link_directories(${AB_LIB_PATHS})
add_executable(${BINNAME} ${AB_VALA_C})
include_directories(${CMAKE_BINARY_DIR}/libambition ${READLINE_INCLUDE_DIR})
add_dependencies(${BINNAME} ${PKGNAME}-${PKGVERSION})
target_link_libraries(${BINNAME} ${CORE_DEPS_LIBRARIES} readline gthread-2.0 ambition-0.1)

install (TARGETS ${BINNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin/)
