project('ambition', ['vala', 'c'],
  version: '0.2.1'
)

pkg = import('pkgconfig')
vala = meson.get_compiler('vala')

message('Found Vala ' + vala.version())
if vala.version().version_compare('<0.26')
    error('Requires Vala >= 0.26')
endif

default_dependencies = [
  dependency('glib-2.0', version: '>=2.32'),
  dependency('gmodule-2.0'),
  dependency('gobject-2.0'),

  dependency('gee-0.8'),
  dependency('gio-2.0'),
  dependency('json-glib-1.0'),
  dependency('libsoup-2.4'),
  dependency('log4vala-0.2'),

  vala.find_library('posix')
]
default_vala_options = [
  '--enable-experimental',
  '--target-glib=2.32',
  '--debug',
  '-g'
]

version_split = meson.project_version().split('.')
api_version = '.'.join([version_split[0], version_split[1]])
library_name = meson.project_name() + '-' + api_version
vapi_dir = meson.current_build_dir() / 'src/libambition'

add_project_arguments(['--vapidir', vapi_dir], language: 'vala')
add_project_arguments(['--includedir', vapi_dir], language: 'vala')
add_project_arguments(
  '-DGETTEXT_PACKAGE="ambition"',
  language: 'c'
)

subdir('src/libambition')
subdir('src/ambition-bin')
subdir('test')
subdir('share')
