sources = [
  'Controller/Root.vala'
]

deps = [
  default_dependencies
]

app_lib = static_library(
  app_name,
  sources: ['Application.vala', sources, template_file_list],
  dependencies: default_dependencies,
  install: false
)

app_bin = executable(
  app_name + '-bin',
  sources: ['Main.vala'],
  dependencies: default_dependencies,
  link_with: app_lib,
  install: false
)
