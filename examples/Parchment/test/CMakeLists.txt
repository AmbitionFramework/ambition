set( BINNAME test-application )

set( APPTEST_VALA_PACKAGES
)

vala_precompile_target(
    "${APPNAME}-test-vala"
    APPTEST_VALA_C
	InitializeTests.vala
	ApplicationTest.vala
    FLAGS
		-g
		--target-glib=2.32
		--vapidir=../src
	    ${APP_PLUGIN_VAPI_LIST}
		--enable-experimental
    PACKAGES
	    ${APPTEST_VALA_PACKAGES}
	    ${APP_VALA_PACKAGES}
	    ${APPNAME}
)

set(APPTEST_CFLAGS
	${APP_CFLAGS}
	-I${CMAKE_BINARY_DIR}/src
)
set(APPTEST_LIB_PATHS
	${APP_LIB_PATHS}
	${CMAKE_BINARY_DIR}/src
)
add_definitions(${APPTEST_CFLAGS})
link_directories( ${APPTEST_LIB_PATHS} )
add_executable(${BINNAME} ${APPTEST_VALA_C})
add_dependencies(${BINNAME} "${PKGNAME}-lib-vala" "${APPNAME}-test-vala")
target_link_libraries(${BINNAME} ${APP_DEPS_LIBRARIES} ${APP_PLUGIN_PACKAGES} ${APPNAME})
add_test_executable(${BINNAME})
