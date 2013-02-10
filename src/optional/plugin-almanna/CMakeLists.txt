set (PPKGNAME ambition-plugin-almanna)
set (PPKGVERSION 0.1.0)

SET( APA_VALA_FILES
	AlmannaPlugin.vala
	StorableAlmanna.vala
	AlmannaSession.vala
	AuthorizerAlmanna.vala
	UserAlmanna.vala
)

SET( APA_DEPS_PACKAGES
    almanna-0.1
)

SET( APA_VALA_PACKAGES
	${CORE_DEPS_PACKAGES}
	${APA_DEPS_PACKAGES}
	ambition-0.1
	posix
)

vala_precompile(APA_VALA_C
	${APA_VALA_FILES}
PACKAGES
    ${APA_VALA_PACKAGES}
OPTIONS
	--thread
    --vapidir=${CMAKE_SOURCE_DIR}/vapi
    --vapidir=${CMAKE_BINARY_DIR}/src/libambition
	--enable-experimental
GENERATE_VAPI
	${PPKGNAME}-${PPKGVERSION}
GENERATE_HEADER
	${PPKGNAME}-${PPKGVERSION})

find_package(PkgConfig)
pkg_check_modules(APA_DEPS REQUIRED ${APA_DEPS_PACKAGES})
set(APA_CFLAGS
	${CORE_DEPS_CFLAGS_ALL}
    ${APA_DEPS_CFLAGS}
    ${APA_DEPS_CFLAGS_OTHER}
    -I${CMAKE_BINARY_DIR}/src/libambition
    -w
)
set(APA_LIB_PATHS
	${CORE_DEPS_LIBRARY_DIRS}
    ${APA_DEPS_LIBRARY_DIRS}
)
link_directories(${APA_LIB_PATHS})
add_definitions(${APA_CFLAGS})

add_library(${PPKGNAME}-${PPKGVERSION} SHARED ${APA_VALA_C})
target_link_libraries(${PPKGNAME}-${PPKGVERSION} ${CORE_DEPS_LIBRARIES} ${APA_DEPS_LIBRARIES} ambition-0.1)

add_subdirectory(test)

file(COPY ${CMAKE_SOURCE_DIR}/src/optional/plugin-almanna/share/scaffold-plugin-almanna DESTINATION ${CMAKE_BINARY_DIR}/src/optional/plugin-almanna/share/scaffold-plugin-almanna)
install(DIRECTORY ${CMAKE_BINARY_DIR}/src/optional/plugin-almanna/share/scaffold-plugin-almanna DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework)

install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PPKGNAME}-${PPKGVERSION}.vapi ${PPKGNAME}-${PPKGVERSION}.deps manifest.json
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/Almanna-${PPKGVERSION}/)
install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PPKGNAME}-${PPKGVERSION}.h
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/Almanna-${PPKGVERSION}/)
install (
	TARGETS ${PPKGNAME}-${PPKGVERSION}
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/Almanna-${PPKGVERSION}/)
