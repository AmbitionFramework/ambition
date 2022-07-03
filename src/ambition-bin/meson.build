sources = [
  'Binary.vala',
  'Shell.vala'
]

ambition_dep = declare_dependency(
  link_with: ambition_lib,
  include_directories: include_directories('../libambition')
)

deps = [
  default_dependencies,
  dependency('readline'),
  ambition_dep
]

vala_args = [
  default_vala_options,
  '--pkg', library_name
]

ambition_bin = executable(
  'ambition',
  sources: sources,
  dependencies: deps,
  vala_args: vala_args,
  install: true,
  install_dir: [true]
)
