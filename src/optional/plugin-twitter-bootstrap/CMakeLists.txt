set (PPKGNAME ambition-plugin-twitterbootstrap)
set (PPKGVERSION 0.1.0)

SET( APTBS_VALA_FILES
	TwitterBootstrapPlugin.vala
	Form/TBButton.vala
	Form/TBCheckboxGroupInput.vala
	Form/TBGroupInput.vala
	Form/TBPasswordInput.vala
	Form/TBRadioGroupInput.vala
	Form/TBResetButton.vala
	Form/TBSelectGroupInput.vala
	Form/TBSubmitButton.vala
	Form/TBTextInput.vala
)

SET( APTBS_VALA_PACKAGES
	${CORE_DEPS_PACKAGES}
	ambition-0.1
	posix
)

vala_precompile(APTBS_VALA_C
	${APTBS_VALA_FILES}
PACKAGES
    ${APTBS_VALA_PACKAGES}
OPTIONS
	--thread
	--vapidir=${CMAKE_SOURCE_DIR}/src/optional/plugin-twitter-bootstrap
    --vapidir=${CMAKE_SOURCE_DIR}/vapi
    --vapidir=${CMAKE_BINARY_DIR}/src/libambition
	--enable-experimental
GENERATE_VAPI
	${PPKGNAME}-${PPKGVERSION}
GENERATE_HEADER
	${PPKGNAME}-${PPKGVERSION})

find_package(PkgConfig)
set(APTBS_CFLAGS
	${CORE_DEPS_CFLAGS_ALL}

    -I${CMAKE_BINARY_DIR}/src/libambition
    -w
)
set(APTBS_LIB_PATHS ${APTBS_DEPS_LIBRARY_DIRS})
link_directories(${APTBS_LIB_PATHS})
add_definitions(${APTBS_CFLAGS})

add_library(${PPKGNAME}-${PPKGVERSION} SHARED ${APTBS_VALA_C})
target_link_libraries(${PPKGNAME}-${PPKGVERSION} ${CORE_DEPS_LIBRARIES} ${APTBS_DEPS_LIBRARIES} ambition-0.1)

add_subdirectory(test)

install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PPKGNAME}-${PPKGVERSION}.vapi ${PPKGNAME}-${PPKGVERSION}.deps manifest.json documentation.md
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/TwitterBootstrap-${PPKGVERSION}/)
install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PPKGNAME}-${PPKGVERSION}.h
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/TwitterBootstrap-${PPKGVERSION}/)
install (
	TARGETS ${PPKGNAME}-${PPKGVERSION}
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/TwitterBootstrap-${PPKGVERSION}/)
