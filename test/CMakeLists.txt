set (BINNAME test-ambition)

include(ValaPrecompile)

SET( TA_VALA_PACKAGES
	${CORE_DEPS_PACKAGES}
	ambition-0.1
	posix
)

vala_precompile(TA_VALA_C 
	test-runner.vala
	actionbuilder.vala
	config.vala
	cookie.vala
	engine.vala
	session.vala
	stash.vala
	authorizer.vala
	password_type.vala
	request.vala
	form.vala
	formfield.vala
	formvalidator.vala
	httpmethod.vala
	controller_static.vala
	coreview_file.vala
	coreview_none.vala
	coreview_redirect.vala
	coreview_json.vala
	pluginloader.vala
	assets/formsubclass.vala
PACKAGES
	${TA_VALA_PACKAGES}
	${PKGNAME}-${PKGVERSION}
OPTIONS
	-g
	--thread
	--vapidir ../src/libambition
	--enable-experimental)

set(TA_CFLAGS
	${CORE_DEPS_CFLAGS_ALL}
	-I${CMAKE_BINARY_DIR}/src/libambition
	-w
)
set(TA_LIB_PATHS
	${CORE_DEPS_LIBRARY_DIRS}
	${CMAKE_BINARY_DIR}/src/libambition
)
add_definitions(${TA_CFLAGS})
link_directories(${TA_LIB_PATHS})

add_executable(${BINNAME} ${TA_VALA_C})
include_directories(${CMAKE_BINARY_DIR}/src/libambition)
add_dependencies(${BINNAME} ${PKGNAME}-${PKGVERSION})
target_link_libraries(${BINNAME} ${CORE_DEPS_LIBRARIES} gthread-2.0 ambition-0.1)
include(Tests)
add_test_executable(${BINNAME})
file(COPY ${CMAKE_SOURCE_DIR}/test/assets/htpasswd DESTINATION ${CMAKE_BINARY_DIR}/test/assets)
file(COPY ${CMAKE_SOURCE_DIR}/test/assets/flat_file DESTINATION ${CMAKE_BINARY_DIR}/test/assets)
file(COPY ${CMAKE_SOURCE_DIR}/test/assets/example.conf DESTINATION ${CMAKE_BINARY_DIR}/test/assets)
set(ENV{LD_LIBRARY_PATH} "${CMAKE_BINARY_DIR}/libambition:$ENV{LD_LIBRARY_PATH}")
