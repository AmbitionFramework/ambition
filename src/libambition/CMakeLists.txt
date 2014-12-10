SET( LAM_VALA_FILES
	Action.vala
	Actions.vala
	ActionBuilder.vala
	ActionMethod.vala
	App.vala
	Application.vala
	Component.vala
	Config.vala
	Cookie.vala
	Dispatcher.vala
	DispatcherUtils.vala
	HttpMethod.vala
	IActionFilter.vala
	Logger.vala
	Request.vala
	RequestFile.vala
	Response.vala
	Result.vala
	Stash.vala
	State.vala
	TemplateCompiler.vala
	Engine/Base.vala
	Engine/Raw.vala
	Engine/Test.vala
	Authorization/Builder.vala
	Authorization/Authorize.vala
	Authorization/IAuthorizer.vala
	Authorization/IUser.vala
	Authorization/IPasswordType.vala
	Authorization/Authorizer/Htpasswd.vala
	Authorization/Authorizer/Flat.vala
	Authorization/User/Htpasswd.vala
	Authorization/User/Flat.vala
	Authorization/PasswordType/Hashed.vala
	Authorization/PasswordType/SHA1.vala
	Authorization/PasswordType/SHA256.vala
	Authorization/PasswordType/MD5.vala
	Controller/Static.vala
	CoreView/File.vala
	CoreView/JSON.vala
	CoreView/None.vala
	CoreView/Redirect.vala
	CoreView/RawString.vala
	CoreView/Template.vala
	Form/Button.vala
	Form/CheckboxGroupInput.vala
	Form/GroupInput.vala
	Form/FieldRenderer.vala
	Form/FormDefinition.vala
	Form/HiddenInput.vala
	Form/Tag.vala
	Form/TextInput.vala
	Form/PasswordInput.vala
	Form/RadioGroupInput.vala
	Form/ResetButton.vala
	Form/SelectGroupInput.vala
	Form/SubmitButton.vala
	Form/Textarea.vala
	Form/Validator.vala
	Plugin/HttpPluginService.vala
	Plugin/IPluginService.vala
	Plugin/LocalPluginService.vala
	Plugin/PluginManifest.vala
	Plugin/PluginResult.vala
	PluginSupport/IPlugin.vala
	PluginSupport/PluginLoader.vala
	Session/Interface.vala
	Session/IStorable.vala
	Session/SessionPlugin.vala
	Session/StorableFile.vala
	Session/StorableMemory.vala
	Testing/AbstractTestCase.vala
	Testing/Helper.vala
	Testing/TestResponse.vala
	Utility/Clean.vala
	Utility/Creator.vala
	Utility/IUtility.vala
	Utility/Monitor.vala
	Utility/Run.vala
	Utility/Plugin.vala
	Utility/Scaffold.vala
	Utility/ScaffoldManifest.vala
	Utility/Utility.vala
	Utility/UtilityLoader.vala
)

SET( LAM_VALA_PACKAGES
	${CORE_DEPS_PACKAGES}
	posix
)

vala_precompile(LAM_VALA_C
	${LAM_VALA_FILES}
PACKAGES
	${LAM_VALA_PACKAGES}
OPTIONS
	${DEFAULT_VALA_OPTIONS}
GENERATE_VAPI
	${PKGNAME}-${PKGVERSION}
GENERATE_HEADER
	${PKGNAME}-${PKGVERSION})

set(LAM_CFLAGS
	${CORE_DEPS_CFLAGS_ALL}
	-w
)
set(LAM_LIB_PATHS
	${CORE_DEPS_LIBRARY_DIRS}
)
link_directories(${LAM_LIB_PATHS})
add_definitions(${LAM_CFLAGS})

add_library(${PKGNAME}-${PKGVERSION} SHARED ${LAM_VALA_C})
target_link_libraries(${PKGNAME}-${PKGVERSION} ${CORE_DEPS_LIBRARIES})
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/${PKGNAME}-${PKGVERSION}.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}-${PKGVERSION}.pc)

install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}-${PKGVERSION}.vapi ${PKGNAME}-${PKGVERSION}.deps
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi/)
install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}-${PKGVERSION}.h
	DESTINATION ${CMAKE_INSTALL_PREFIX}/include/)
install (
	FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}-${PKGVERSION}.pc
	DESTINATION ${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_DIR}/pkgconfig/)
install (
	TARGETS ${PKGNAME}-${PKGVERSION}
	DESTINATION ${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_DIR}/)
