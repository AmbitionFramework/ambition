set (BINNAME test-ambition-plugin-almanna)

include(ValaPrecompile)

SET( TAPA_VALA_PACKAGES
    ambition-0.1
    ambition-plugin-almanna-${PPKGVERSION}
    posix
    ${CORE_DEPS_PACKAGES}
	${APA_DEPS_PACKAGES}
)

vala_precompile(TAPA_VALA_C
    UserEntity.vala
	AlmannaTest.vala
PACKAGES
    ${TAPA_VALA_PACKAGES}
    ${PKGNAME}-${PKGVERSION}
OPTIONS
    -g
	--thread
    --vapidir ${CMAKE_BINARY_DIR}/src/libambition
    --vapidir ${CMAKE_BINARY_DIR}/src/optional/plugin-almanna
	--enable-experimental)

set(TAPA_CFLAGS
    ${CORE_DEPS_CFLAGS_ALL}
    ${APA_DEPS_CFLAGS}
    ${APA_DEPS_CFLAGS_OTHER}
    -I${CMAKE_BINARY_DIR}/src/libambition
    -I${CMAKE_BINARY_DIR}/src/optional/plugin-almanna
    -w
)
set(TAPA_LIB_PATHS
    ${CORE_DEPS_LIBRARY_DIRS}
    ${APA_DEPS_LIBRARY_DIRS}
    -L${CMAKE_BINARY_DIR}/src/libambition
    -L${CMAKE_BINARY_DIR}/src/optional/plugin-almanna
)
add_definitions(${TAPA_CFLAGS})

add_executable(${BINNAME} ${TAPA_VALA_C})
include_directories(${CMAKE_BINARY_DIR}/src/libambition ${CMAKE_BINARY_DIR}/src/optional/plugin-almanna)
add_dependencies(${BINNAME} ${PKGNAME}-${PKGVERSION})
target_link_libraries(${BINNAME} ${CORE_DEPS_LIBRARIES} ${APA_DEPS_LIBRARIES} gthread-2.0 ambition-plugin-almanna-${PPKGVERSION})
include(Tests)
add_test_executable(${BINNAME})
file(COPY ${CMAKE_SOURCE_DIR}/src/optional/plugin-almanna/test/test.db DESTINATION ${CMAKE_BINARY_DIR}/src/optional/plugin-almanna/test/)
set(ENV{LD_LIBRARY_PATH} "${CMAKE_BINARY_DIR}/src/libambition:..:$ENV{LD_LIBRARY_PATH}")
