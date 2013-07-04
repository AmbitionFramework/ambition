set ( BINNAME test-application )

include(ValaPrecompile)

SET( APPTEST_VALA_PACKAGES
)

vala_precompile(APPTEST_VALA_C 
	InitializeTests.vala
	ApplicationTest.vala
PACKAGES
    ${APPTEST_VALA_PACKAGES}
    ${APP_VALA_PACKAGES}
    ${APPNAME}
OPTIONS
	-g
	--thread
	--vapidir=../src
    ${APP_PLUGIN_VAPI_LIST}
	--enable-experimental)

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
target_link_libraries(${BINNAME} ${APP_DEPS_LIBRARIES} ${APP_PLUGIN_PACKAGES} ${APPNAME} gthread-2.0)
include(Tests)
add_test_executable(${BINNAME})
