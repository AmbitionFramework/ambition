sources = [
]

deps = [
  default_dependencies,
  declare_dependency(
    link_with: app_lib,
    include_directories: include_directories('../src')
  )
]

app_test = executable(
  'test-application',
  sources: ['InitializeTests.vala', 'ApplicationTest.vala', sources],
  dependencies: deps,
  install: false
)

test(app_name + ' test', app_test,
  env: [
    'G_TEST_SRCDIR=@0@'.format(meson.current_source_dir()),
    'G_TEST_BUILDDIR=@0@'.format(meson.current_build_dir()),
  ],
  workdir: meson.current_source_dir() + '/..',
  protocol: 'tap'
)
