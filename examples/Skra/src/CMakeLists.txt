SET( APP_VALA_FILES
    Controller/Root.vala
    Controller/Wiki.vala
    Controller/Auth.vala
    Form/Login.vala
    Model/WikiMarkdown.vala
    Model/WikiNode.vala
)

vala_precompile_target(
    "${APPNAME}-lib-vala"
    APPLIB_VALA_C
    FLAGS
        --thread
        ${APP_PLUGIN_VAPI_LIST}
        --enable-experimental
    PACKAGES ${APP_VALA_PACKAGES}
    VAPI "${CMAKE_CURRENT_BINARY_DIR}/${APPNAME}.vapi"
    HEADER "${CMAKE_CURRENT_BINARY_DIR}/${APPNAME}.h"
    Application.vala
    .generated/Actions.vala
    ${TEMPLATE_FILE_LIST}
    ${APP_VALA_FILES}
)

vala_precompile_target(
    "${APPNAME}-bin-vala"
    APPBIN_VALA_C
    Main.vala
    FLAGS
        --thread
        --enable-experimental
        --vapidir=.
        ${APP_PLUGIN_VAPI_LIST}
        --debug
    PACKAGES ${APP_VALA_PACKAGES}
             ${APPNAME}
)

set(APP_CFLAGS
    ${APP_DEPS_CFLAGS}
    ${APP_DEPS_CFLAGS_OTHER}
    -I${CMAKE_CURRENT_BINARY_DIR}
    ${APP_PLUGIN_INCLUDE_LIST}
)
set(APP_LIB_PATHS
    ${APP_DEPS_LIBRARY_DIRS}
    ${APP_PLUGIN_LIBRARY_DIRS}
)
add_definitions(${APP_CFLAGS})

link_directories( ${APP_LIB_PATHS} )
add_library(${APPNAME} SHARED ${APPLIB_VALA_C})
add_dependencies(${APPNAME} "${APPNAME}-lib-vala")
add_executable(${BINNAME} ${APPBIN_VALA_C})
add_dependencies(${BINNAME} "${APPNAME}-lib-vala" "${APPNAME}-bin-vala")
target_link_libraries(${APPNAME} ${APP_DEPS_LIBRARIES} ${APP_PLUGIN_PACKAGES} markdown gthread-2.0)
target_link_libraries(${BINNAME} ${APPNAME} gthread-2.0)

install (TARGETS ${APPNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin/)
install (TARGETS ${BINNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin/)
