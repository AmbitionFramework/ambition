set (BINNAME test-ambition-plugin-couchdb)

include(ValaPrecompile)

SET( TAPC_VALA_PACKAGES
    ambition-0.1
    ambition-plugin-couchdb-${PPKGVERSION}
    posix
    couchdb-glib-1.0
    ${CORE_DEPS_PACKAGES}
	${APA_DEPS_PACKAGES}
)

vala_precompile(TAPC_VALA_C
    CouchdbTest.vala
PACKAGES
    ${TAPC_VALA_PACKAGES}
    ${PKGNAME}-${PKGVERSION}
OPTIONS
    -g
	--thread
    --vapidir ${CMAKE_SOURCE_DIR}/src/optional/plugin-couchdb
    --vapidir ${CMAKE_BINARY_DIR}/src/optional/plugin-couchdb
    --vapidir ${CMAKE_BINARY_DIR}/src/libambition
	--enable-experimental)

set(TAPC_CFLAGS
    ${CORE_DEPS_CFLAGS_ALL}
    ${APA_DEPS_CFLAGS}
    ${APA_DEPS_CFLAGS_OTHER}
    -I${CMAKE_BINARY_DIR}/src/libambition
    -I${CMAKE_BINARY_DIR}/src/optional/plugin-couchdb
    -w
)
set(TAPC_LIB_PATHS
    ${CORE_DEPS_LIBRARY_DIRS}
    ${APA_DEPS_LIBRARY_DIRS}
    ${CMAKE_BINARY_DIR}/src/libambition
    ${CMAKE_BINARY_DIR}/src/optional/plugin-couchdb
)
link_directories(${TAPC_LIB_PATHS})
add_definitions(${TAPC_CFLAGS})

add_executable(${BINNAME} ${TAPC_VALA_C})
include_directories(${CMAKE_BINARY_DIR}/srclibambition ${CMAKE_BINARY_DIR}/src/optional/plugin-couchdb)
add_dependencies(${BINNAME} ${PKGNAME}-${PKGVERSION})
target_link_libraries(${BINNAME} ${CORE_DEPS_LIBRARIES} ${APA_DEPS_LIBRARIES} gthread-2.0 ambition-plugin-couchdb-${PPKGVERSION})
include(Tests)
add_test_executable(${BINNAME})
set(ENV{LD_LIBRARY_PATH} "${CMAKE_BINARY_DIR}/libambition:..:$ENV{LD_LIBRARY_PATH}")
