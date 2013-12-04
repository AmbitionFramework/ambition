set (BINNAME test-ambition-plugin-servicething)

include(ValaPrecompile)

SET( TAPST_VALA_PACKAGES
    ambition-0.1
    ambition-plugin-servicething-${PPKGVERSION}
    posix
    ${CORE_DEPS_PACKAGES}
	${APST_DEPS_PACKAGES}
)

vala_precompile(TAPST_VALA_C
    ServiceThingTest.vala
PACKAGES
    ${TAPST_VALA_PACKAGES}
    ${PKGNAME}-${PKGVERSION}
OPTIONS
    -g
	--thread
    --vapidir ${CMAKE_BINARY_DIR}/src/libambition
    --vapidir ${CMAKE_BINARY_DIR}/src/optional/plugin-servicething
	--enable-experimental)

set(TAPST_CFLAGS
    -I${CMAKE_BINARY_DIR}/src/libambition
    -I${CMAKE_BINARY_DIR}/src/optional/plugin-servicething
    ${CORE_DEPS_CFLAGS_ALL}
    ${APST_DEPS_CFLAGS}
    ${APST_DEPS_CFLAGS_OTHER}
    -w
)
set(TAPST_LIB_PATHS
    ${CORE_DEPS_LIBRARY_DIRS}
    ${APST_DEPS_LIBRARY_DIRS}
    ${CMAKE_BINARY_DIR}/src/libambition
    ${CMAKE_BINARY_DIR}/src/optional/plugin-servicething
)
link_directories(${TAPST_LIB_PATHS})
add_definitions(${TAPST_CFLAGS})

add_executable(${BINNAME} ${TAPST_VALA_C})
include_directories(${CMAKE_BINARY_DIR}/src/libambition ${CMAKE_BINARY_DIR}/src/optional/plugin-servicething)
add_dependencies(${BINNAME} ${PKGNAME}-${PKGVERSION})
target_link_libraries(${BINNAME} ${CORE_DEPS_LIBRARIES} ${APST_DEPS_LIBRARIES} gthread-2.0 ambition-plugin-servicething-${PPKGVERSION})
include(Tests)
add_test_executable(${BINNAME})
set(ENV{LD_LIBRARY_PATH} "${CMAKE_BINARY_DIR}/src/libambition:..:$ENV{LD_LIBRARY_PATH}")
