set (PPKGNAME ambition-engine-scgi)
set (PPKGVERSION 0.1.0)

SET( AES_VALA_FILES
	SCGI.vala
	SCGIPlugin.vala
	SCGIUtility.vala
)

SET( AES_DEPS_PACKAGES
    libgscgi-1.0
)

SET( AES_VALA_PACKAGES
	${CORE_DEPS_PACKAGES}
	${AES_DEPS_PACKAGES}
	ambition-0.1
	posix
)

vala_precompile(AES_VALA_C
	${AES_VALA_FILES}
PACKAGES
    ${AES_VALA_PACKAGES}
OPTIONS
	--thread
    --vapidir=${CMAKE_SOURCE_DIR}/vapi
    --vapidir=${CMAKE_BINARY_DIR}/src/libambition
	--enable-experimental
GENERATE_VAPI
	${PPKGNAME}-${PPKGVERSION}
GENERATE_HEADER
	${PPKGNAME}-${PPKGVERSION}
)

find_package(PkgConfig)
pkg_check_modules(AES_DEPS REQUIRED ${AES_DEPS_PACKAGES})
set(AES_CFLAGS
    -I${CMAKE_BINARY_DIR}/src/libambition
    ${CORE_DEPS_CFLAGS_ALL}
    ${AES_DEPS_CFLAGS}
    ${AES_DEPS_CFLAGS_OTHER}
    -w
)
set(AES_LIB_PATHS
    ${AES_DEPS_LIBRARY_DIRS}
	${CMAKE_BINARY_DIR}/src/libambition
)
link_directories(${AES_LIB_PATHS})
add_definitions(${AES_CFLAGS})

add_library(${PPKGNAME}-${PPKGVERSION} SHARED ${AES_VALA_C})
target_link_libraries(${PPKGNAME}-${PPKGVERSION} ${AES_DEPS_LIBRARIES} ambition-0.1)

file(
	COPY ${CMAKE_SOURCE_DIR}/src/optional/engine-scgi/share/scaffold-engine-scgi
	DESTINATION ${CMAKE_BINARY_DIR}/src/optional/engine-scgi/share/scaffold-engine-scgi
)
install(
	DIRECTORY ${CMAKE_BINARY_DIR}/src/optional/engine-scgi/share/scaffold-engine-scgi
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework
)
install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PPKGNAME}-${PPKGVERSION}.vapi ${PPKGNAME}-${PPKGVERSION}.deps manifest.json documentation.md
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/SCGI-${PPKGVERSION}/
)
install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PPKGNAME}-${PPKGVERSION}.h
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/SCGI-${PPKGVERSION}/
)
install (
	TARGETS ${PPKGNAME}-${PPKGVERSION}
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/SCGI-${PPKGVERSION}/
)
