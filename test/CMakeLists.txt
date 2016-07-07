set (BINNAME test-ambition)

SET( TA_VALA_PACKAGES
	${CORE_DEPS_PACKAGES}
	ambition-0.1
	posix
)

SET( TA_VALA_FILES
	test-runner.vala
	actionbuilder.vala
	app.vala
	build.vala
	config.vala
	cookie.vala
	dispatcher.vala
	engine.vala
	pluginmanifest.vala
	session.vala
	stash.vala
	templatecompiler.vala
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
	coreview_rawstring.vala
	coreview_redirect.vala
	coreview_json.vala
	pluginloader.vala
	assets/formsubclass.vala
)

vala_precompile_target(
	"${PKGNAME}-test-vala"
	TA_VALA_C
	${TA_VALA_FILES}
	FLAGS
		-g
		--thread
		--vapidir "../src/libambition/${PKGNAME}-${PKGVERSION}-vala/sources"
		--vapidir "../src/libambition"
		--enable-experimental
	PACKAGES ${TA_VALA_PACKAGES}
	         ${PKGNAME}-${PKGVERSION}
)

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
add_dependencies(${BINNAME} "${PKGNAME}-${PKGVERSION}-vala")
target_link_libraries(${BINNAME} ${CORE_DEPS_LIBRARIES} gthread-2.0 ambition-0.1)
add_test_executable(${BINNAME})
file(COPY ${CMAKE_SOURCE_DIR}/test/assets/htpasswd DESTINATION ${CMAKE_BINARY_DIR}/test/assets)
file(COPY ${CMAKE_SOURCE_DIR}/test/assets/flat_file DESTINATION ${CMAKE_BINARY_DIR}/test/assets)
file(COPY ${CMAKE_SOURCE_DIR}/test/assets/example.conf DESTINATION ${CMAKE_BINARY_DIR}/test/assets)
file(COPY ${CMAKE_SOURCE_DIR}/test/assets/build.conf DESTINATION ${CMAKE_BINARY_DIR}/test/assets)
set(ENV{LD_LIBRARY_PATH} "${CMAKE_BINARY_DIR}/libambition:$ENV{LD_LIBRARY_PATH}")
