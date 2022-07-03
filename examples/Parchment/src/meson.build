sources = [
  'Controller/Entries.vala',
  'Controller/Admin.vala',
  'Controller/Callback.vala',
  'Form/Reply.vala',
  'Form/Profile.vala',
  'Form/Login.vala',
  'Form/Entry.vala',
  'Model/DB/AlmannaLoader.vala',
  'Model/DB/Entity/Entry.vala',
  'Model/DB/Entity/EntryTag.vala',
  'Model/DB/Entity/Publisher.vala',
  'Model/DB/Entity/Session.vala',
  'Model/DB/Entity/Tag.vala',
  'Model/DB/Implementation/Entry.vala',
  'Model/DB/Implementation/EntryTag.vala',
  'Model/DB/Implementation/Publisher.vala',
  'Model/DB/Implementation/Session.vala',
  'Model/DB/Implementation/Tag.vala',
  
  'Model/DB/Entity/Comment.vala',
  'Model/DB/Implementation/Comment.vala'
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
