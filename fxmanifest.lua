fx_version 'cerulean'
game 'gta5'

author 'Hoàng Đức'
version '1.0.0'
description 'MojiaVehicleKeys - Best vehicle keys for MojiaCity Framework'

shared_scripts {
	'@qb-core/shared/locale.lua',
    	'locales/en.lua', -- Change this to your preferred language
	'config.lua'
}
client_script 'client.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

lua54 'yes'
