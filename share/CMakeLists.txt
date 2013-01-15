file(COPY ${CMAKE_SOURCE_DIR}/share/ambition-framework DESTINATION ${CMAKE_BINARY_DIR}/share)
install(DIRECTORY ${CMAKE_BINARY_DIR}/share/ambition-framework DESTINATION ${CMAKE_INSTALL_PREFIX}/share)