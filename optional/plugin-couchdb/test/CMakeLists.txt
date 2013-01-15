set (BINNAME test-ambition-plugin-couchdb)

include(ValaPrecompile)

SET( TAPA_VALA_PACKAGES
    ambition-0.1
    ambition-plugin-couchdb-${PPKGVERSION}
    posix
    couchdb-glib-1.0
    ${CORE_DEPS_PACKAGES}
	${APA_DEPS_PACKAGES}
)

vala_precompile(TAPA_VALA_C
    CouchdbTest.vala
PACKAGES
    ${TAPA_VALA_PACKAGES}
    ${PKGNAME}-${PKGVERSION}
OPTIONS
    -g
	--thread
    --vapidir ${CMAKE_SOURCE_DIR}/optional/plugin-couchdb
    --vapidir ${CMAKE_BINARY_DIR}/optional/plugin-couchdb
    --vapidir ${CMAKE_BINARY_DIR}/libambition
	--enable-experimental)

set(TAPA_CFLAGS
    ${CORE_DEPS_CFLAGS_ALL}
    ${APA_DEPS_CFLAGS}
    ${APA_DEPS_CFLAGS_OTHER}
    -I${CMAKE_BINARY_DIR}/libambition
    -I${CMAKE_BINARY_DIR}/optional/plugin-couchdb
    -w
)
set(TAPA_LIB_PATHS
    ${CORE_DEPS_LIBRARY_DIRS}
    ${APA_DEPS_LIBRARY_DIRS}
    -L${CMAKE_BINARY_DIR}/libambition
    -L${CMAKE_BINARY_DIR}/optional/plugin-couchdb
)
add_definitions(${TAPA_CFLAGS})

add_executable(${BINNAME} ${TAPA_VALA_C})
include_directories(${CMAKE_BINARY_DIR}/libambition ${CMAKE_BINARY_DIR}/optional/plugin-couchdb)
add_dependencies(${BINNAME} ${PKGNAME}-${PKGVERSION})
target_link_libraries(${BINNAME} ${CORE_DEPS_LIBRARIES} ${APA_DEPS_LIBRARIES} gthread-2.0 ambition-plugin-couchdb-${PPKGVERSION})
include(Tests)
add_test_executable(${BINNAME})
set(ENV{LD_LIBRARY_PATH} "${CMAKE_BINARY_DIR}/libambition:..:$ENV{LD_LIBRARY_PATH}")
