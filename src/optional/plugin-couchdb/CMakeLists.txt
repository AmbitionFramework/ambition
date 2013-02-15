set (PPKGNAME ambition-plugin-couchdb)
set (PPKGVERSION 0.1.0)

SET( APCDB_VALA_FILES
	Couch.vala
	CouchPlugin.vala
	Document.vala
	SessionDocument.vala
	StorableCouch.vala
)

SET( APCDB_DEPS_PACKAGES
	couchdb-glib-1.0
)

SET( APCDB_VALA_PACKAGES
	${CORE_DEPS_PACKAGES}
	${APCDB_DEPS_PACKAGES}
	ambition-0.1
	posix
)

vala_precompile(APCDB_VALA_C
	${APCDB_VALA_FILES}
PACKAGES
    ${APCDB_VALA_PACKAGES}
OPTIONS
	--thread
	--vapidir=${CMAKE_SOURCE_DIR}/src/optional/plugin-couchdb
    --vapidir=${CMAKE_SOURCE_DIR}/vapi
    --vapidir=${CMAKE_BINARY_DIR}/src/libambition
	--enable-experimental
GENERATE_VAPI
	${PPKGNAME}-${PPKGVERSION}
GENERATE_HEADER
	${PPKGNAME}-${PPKGVERSION})

find_package(PkgConfig)
pkg_check_modules(APCDB_DEPS REQUIRED ${APCDB_DEPS_PACKAGES})
set(APCDB_CFLAGS
	${CORE_DEPS_CFLAGS_ALL}
    ${APCDB_DEPS_CFLAGS}
    ${APCDB_DEPS_CFLAGS_OTHER}
    -I/usr/include/couchdb-glib-1.0
    -I${CMAKE_BINARY_DIR}/src/libambition
    -w
)
set(APCDB_LIB_PATHS ${APCDB_DEPS_LIBRARY_DIRS})
link_directories(${APCDB_LIB_PATHS})
add_definitions(${APCDB_CFLAGS})

add_library(${PPKGNAME}-${PPKGVERSION} SHARED ${APCDB_VALA_C})
target_link_libraries(${PPKGNAME}-${PPKGVERSION} ${CORE_DEPS_LIBRARIES} ${APCDB_DEPS_LIBRARIES} ambition-0.1)

add_subdirectory(test)

install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PPKGNAME}-${PPKGVERSION}.vapi ${CMAKE_SOURCE_DIR}/src/optional/plugin-couchdb/couchdb-glib-1.0.vapi ${PPKGNAME}-${PPKGVERSION}.deps manifest.json documentation.md
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/CouchDB-${PPKGVERSION}/)
install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PPKGNAME}-${PPKGVERSION}.h
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/CouchDB-${PPKGVERSION}/)
install (
	TARGETS ${PPKGNAME}-${PPKGVERSION}
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/CouchDB-${PPKGVERSION}/)
