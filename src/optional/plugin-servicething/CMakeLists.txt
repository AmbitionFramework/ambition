set (PPKGNAME ambition-plugin-servicething)
set (PPKGVERSION 0.1.0)

SET( APST_VALA_FILES
	ServiceThingPlugin.vala
	Service.vala
	Serializer/ISerializer.vala
	Serializer/JSON.vala
)

SET( APST_DEPS_PACKAGES
	json-glib-1.0
)

SET( APST_VALA_PACKAGES
	${CORE_DEPS_PACKAGES}
	${APST_DEPS_PACKAGES}
	ambition-0.1
	posix
)

vala_precompile(APST_VALA_C
	${APST_VALA_FILES}
PACKAGES
	${APST_VALA_PACKAGES}
OPTIONS
	--thread
	--vapidir=${CMAKE_SOURCE_DIR}/src/optional/plugin-servicething
	--vapidir=${CMAKE_SOURCE_DIR}/vapi
	--vapidir=${CMAKE_BINARY_DIR}/src/libambition
	--enable-experimental
GENERATE_VAPI
	${PPKGNAME}-${PPKGVERSION}
GENERATE_HEADER
	${PPKGNAME}-${PPKGVERSION})

find_package(PkgConfig)
pkg_check_modules(APST_DEPS REQUIRED ${APST_DEPS_PACKAGES})
set(APST_CFLAGS
	${CORE_DEPS_CFLAGS_ALL}
	${APST_DEPS_CFLAGS}
	${APST_DEPS_CFLAGS_OTHER}
	-I${CMAKE_BINARY_DIR}/src/libambition
	-w
)
set(APST_LIB_PATHS
	${APST_DEPS_LIBRARY_DIRS}
	${CMAKE_BINARY_DIR}/src/libambition
)
link_directories(${APST_LIB_PATHS})
add_definitions(${APST_CFLAGS})

add_library(${PPKGNAME}-${PPKGVERSION} SHARED ${APST_VALA_C})
target_link_libraries(${PPKGNAME}-${PPKGVERSION} ${CORE_DEPS_LIBRARIES} ${APST_DEPS_LIBRARIES} ambition-0.1)

add_subdirectory(test)

install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PPKGNAME}-${PPKGVERSION}.vapi ${PPKGNAME}-${PPKGVERSION}.deps manifest.json documentation.md
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/ServiceThing-${PPKGVERSION}/)
install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PPKGNAME}-${PPKGVERSION}.h
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/ServiceThing-${PPKGVERSION}/)
install (
	TARGETS ${PPKGNAME}-${PPKGVERSION}
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/ServiceThing-${PPKGVERSION}/)
