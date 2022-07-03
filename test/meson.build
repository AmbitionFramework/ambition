sources = [
  'app.vala',
  'authorizer.vala',
  'build.vala',
  'config.vala',
  'controllermethod.vala',
  'controller_static.vala',
  'cookie.vala',
  'coreview_file.vala',
  'coreview_json.vala',
  'coreview_none.vala',
  'coreview_rawstring.vala',
  'coreview_redirect.vala',
  'dispatcher.vala',
  'engine.vala',
  'formfield.vala',
  'form.vala',
  'formvalidator.vala',
  'httpmethod.vala',
  'password_type.vala',
  'pluginloader.vala',
  'pluginmanifest.vala',
  'request.vala',
  'route.vala',
  'serializer_json.vala',
  'serializer_responsehelper.vala',
  'session.vala',
  'stash.vala',
  'templatecompiler.vala',
  'test-runner.vala',
  'assets/formsubclass.vala',
  'assets/serializer-test-classes.vala',
]

deps = [
  default_dependencies,
  declare_dependency(
    link_with: ambition_lib,
    include_directories: include_directories('../src/libambition')
  )
]

vala_args = [default_vala_options]

ambition_test = executable(
  'test-ambition',
  sources: sources,
  dependencies: deps,
  vala_args: vala_args,
  install: false
)

test('ambition test', ambition_test,
  env: [
    'G_TEST_SRCDIR=@0@'.format(meson.current_source_dir()),
    'G_TEST_BUILDDIR=@0@'.format(meson.current_build_dir()),
  ],
  workdir: meson.current_source_dir(),
  protocol: 'tap'
)
