set (BINNAME test-ambition-plugin-twitterbootstrap)

include(ValaPrecompile)

SET( TAPBS_VALA_PACKAGES
	${CORE_DEPS_PACKAGES}
    ambition-0.1
    ambition-plugin-twitterbootstrap-${PPKGVERSION}
	posix
)

vala_precompile(TAPBS_VALA_C
    TwitterBootstrapTest.vala
	TBTextInputTest.vala
    TBButtonTest.vala
PACKAGES
    ${TAPBS_VALA_PACKAGES}
    ${PKGNAME}-${PKGVERSION}
OPTIONS
    -g
	--thread
    --vapidir ${CMAKE_BINARY_DIR}/src/libambition
    --vapidir ${CMAKE_BINARY_DIR}/src/optional/plugin-twitter-bootstrap
	--enable-experimental)

set(TAPBS_CFLAGS
    ${CORE_DEPS_CFLAGS_ALL}
    -I${CMAKE_BINARY_DIR}/src/libambition
    -I${CMAKE_BINARY_DIR}/src/optional/plugin-twitter-bootstrap
    -w
)
set(TAPBS_LIB_PATHS
    ${CORE_DEPS_LIBRARY_DIRS}
    ${CMAKE_BINARY_DIR}/src/libambition
    ${CMAKE_BINARY_DIR}/src/optional/plugin-twitter-bootstrap
)
add_definitions(${TAPBS_CFLAGS})

add_executable(${BINNAME} ${TAPBS_VALA_C})
include_directories(${CMAKE_BINARY_DIR}/src/libambition ${CMAKE_BINARY_DIR}/src/optional/plugin-twitter-bootstrap)
add_dependencies(${BINNAME} ${PPKGNAME}-${PPKGVERSION})
target_link_libraries(${BINNAME} ${TAPBS_DEPS_LIBRARIES} gthread-2.0 ambition-plugin-twitterbootstrap-${PPKGVERSION})
include(Tests)
add_test_executable(${BINNAME})
set(ENV{LD_LIBRARY_PATH} "${CMAKE_BINARY_DIR}/libambition:..:$ENV{LD_LIBRARY_PATH}")
