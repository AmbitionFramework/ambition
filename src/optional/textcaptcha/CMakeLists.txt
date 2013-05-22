set (PPKGNAME ambition-helper-textcaptcha)
set (PPKGVERSION 0.1.0)

SET( AHT_VALA_FILES
	TextCaptcha.vala
	TextCaptchaPlugin.vala
)

SET( AHT_DEPS_PACKAGES
    libsoup-2.4
)

SET( AHT_VALA_PACKAGES
	${CORE_DEPS_PACKAGES}
	${AHT_DEPS_PACKAGES}
	ambition-0.1
	posix
)

vala_precompile(AHT_VALA_C
	${AHT_VALA_FILES}
PACKAGES
    ${AHT_VALA_PACKAGES}
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
pkg_check_modules(AHT_DEPS REQUIRED ${AHT_DEPS_PACKAGES})
set(AHT_CFLAGS
	${CORE_DEPS_CFLAGS_ALL}
    ${AHT_DEPS_CFLAGS}
    ${AHT_DEPS_CFLAGS_OTHER}
    -I${CMAKE_BINARY_DIR}/src/libambition
    -w
)
set(AHT_LIB_PATHS
	${AHT_DEPS_LIBRARY_DIRS}
	${CMAKE_BINARY_DIR}/src/libambition
)
link_directories(${AHT_LIB_PATHS})
add_definitions(${AHT_CFLAGS})

add_library(${PPKGNAME}-${PPKGVERSION} SHARED ${AHT_VALA_C})
target_link_libraries(${PPKGNAME}-${PPKGVERSION} ${CORE_DEPS_LIBRARIES} ${AHT_DEPS_LIBRARIES} ambition-0.1)

add_subdirectory(test)

install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PPKGNAME}-${PPKGVERSION}.vapi ${PPKGNAME}-${PPKGVERSION}.deps manifest.json documentation.md
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/TextCaptcha-${PPKGVERSION}/)
install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PPKGNAME}-${PPKGVERSION}.h
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/TextCaptcha-${PPKGVERSION}/)
install (
	TARGETS ${PPKGNAME}-${PPKGVERSION}
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ambition-framework/plugins/TextCaptcha-${PPKGVERSION}/)
