SET( APP_VALA_FILES
    Controller/Root.vala
    Controller/Wiki.vala
    Controller/Auth.vala
    Form/Login.vala
    Model/WikiMarkdown.vala
    Model/WikiNode.vala
)

vala_precompile(APPLIB_VALA_C 
    Application.vala
    .generated/Actions.vala
    ${TEMPLATE_FILE_LIST}
    ${APP_VALA_FILES}
PACKAGES
    ${APP_VALA_PACKAGES}
OPTIONS
    --thread
    --enable-experimental
    ${APP_PLUGIN_VAPI_LIST}
GENERATE_VAPI
    ${APPNAME}
GENERATE_HEADER
    ${APPNAME})

vala_precompile(APPBIN_VALA_C
    Main.vala
PACKAGES
    ${APP_VALA_PACKAGES}
    ${APPNAME}
OPTIONS
    --thread
    --enable-experimental
    --vapidir=.
    ${APP_PLUGIN_VAPI_LIST}
    --debug)

set(APP_CFLAGS
    ${APP_DEPS_CFLAGS}
    ${APP_DEPS_CFLAGS_OTHER}
    ${APP_PLUGIN_INCLUDE_LIST}
)
set(APP_LIB_PATHS
    ${APP_DEPS_LIBRARY_DIRS}
    ${APP_PLUGIN_LIBRARY_DIRS}
)
add_definitions(${APP_CFLAGS})

link_directories( ${APP_LIB_PATHS} )
add_library(${APPNAME} SHARED ${APPLIB_VALA_C})
add_executable(${BINNAME} ${APPBIN_VALA_C})
target_link_libraries(${APPNAME} ${APP_DEPS_LIBRARIES} ${APP_PLUGIN_PACKAGES} markdown gthread-2.0)
target_link_libraries(${BINNAME} ${APPNAME} gthread-2.0)

install (TARGETS ${APPNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin/)
install (TARGETS ${BINNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin/)
