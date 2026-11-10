fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ender_npczones'
author 'EnderDevelopment'
description 'Admin-managed NPC zones and groups for ESX Legacy'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

dependency 'es_extended'
