fx_version 'cerulean'

game 'gta5'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/*.lua'
}

server_scripts {
    'server/main.lua'
}

shared_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@ox_lib/init.lua',
    'shared/config.lua'
}

lua54 'yes'
