set (BINNAME ambition)
set (PKGNAME ambition)
set (PKGVERSION 0.1)

SET( AB_VALA_PACKAGES
	${CORE_DEPS_PACKAGES}
	readline
	posix
)

vala_precompile(AB_VALA_C
	Utility/Clean.vala
	Utility/Monitor.vala
	Utility/Run.vala
	Utility/Plugin.vala
	Utility/Scaffold.vala
	Utility/ScaffoldManifest.vala
	Utility/Shell.vala
	Utility/Util.vala
	Plugin/IPluginService.vala
	Plugin/HttpPluginService.vala
	Plugin/LocalPluginService.vala
	Plugin/PluginManifest.vala
	Plugin/PluginResult.vala
PACKAGES
	${AB_VALA_PACKAGES}
	${PKGNAME}-${PKGVERSION}
OPTIONS
	--thread
	--vapidir ../libambition
	--enable-experimental
	-g)

set(AB_CFLAGS
	${CORE_DEPS_CFLAGS_ALL}
	-I../libambition
	-w
)
set(AB_LIB_PATHS
	${CORE_DEPS_LIBRARY_DIRS}
	-L../libambition
)
add_definitions(${AB_CFLAGS})

add_executable(${BINNAME} ${AB_VALA_C})
include_directories(${CMAKE_BINARY_DIR}/libambition)
add_dependencies(${BINNAME} ${PKGNAME}-${PKGVERSION})
target_link_libraries(${BINNAME} ${CORE_DEPS_LIBRARIES} ${AB_DEPS_LIBRARIES} readline gthread-2.0 ambition-0.1)

install (TARGETS ${BINNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin/)
