fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'v42'
description 'Automatic config-based hat hair swap. (requested)'
version '1.0.0'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/cl_bridge.lua',
    'client/cl_main.lua',
}

server_scripts {
    'server/sv_bridge.lua',
    'server/sv_main.lua',
}
