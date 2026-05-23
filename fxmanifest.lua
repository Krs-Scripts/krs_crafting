fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name "krs_crafting"
description "React + Mantine"
author "Krs Scripts - karos7804"
version "1.0.0"

shared_scripts {
  '@ox_lib/init.lua',
  'shared/config.lua',
  'framework/framework.lua'
}

client_scripts {
  'client/main.lua'
}

server_scripts {
  'server/main.lua'
}

ui_page 'web/build/index.html'

files {
  'web/build/index.html',
  'web/build/**/*',
  'locales/*.json'
}