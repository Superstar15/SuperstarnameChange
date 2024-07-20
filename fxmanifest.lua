fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Superstar' -- superstar_.
description 'Basic Namechange script'

client_scripts {
    'client/main.lua',
    '@ox_lib/init.lua'
}

shared_scripts {
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'logConfig.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql'
}
