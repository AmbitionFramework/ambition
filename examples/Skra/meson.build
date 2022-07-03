project('Skra', ['vala', 'c'])

app_name = 'Skra'

pkg = import('pkgconfig')
vala = meson.get_compiler('vala')

message('Found Vala ' + vala.version())
if vala.version().version_compare('<0.54')
    error('Requires Vala >= 0.54')
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
  dependency('ambition-0.2'),

  vala.find_library('posix')
]
default_vala_options = [
  '--enable-experimental',
  '--target-glib=2.32',
  '--debug',
  '-g'
]

c_mkdir = run_command('mkdir', '-p', meson.current_source_dir() + '/src/.generated', check: true)
c_template = run_command('ambition', 'template-compile', app_name, meson.current_source_dir() + '/src/View/Template', meson.current_source_dir() + '/src/.generated', check: true)
results = c_template.stdout().strip()
if results.contains('ERROR')
  message(results)
  error('Build aborted')
endif

template_file_list = []
foreach f : results.split('\n')
  template_file_list += f.replace(meson.current_source_dir() + '/src/', '')
endforeach

message(template_file_list)

subdir('src')
subdir('test')
