fx_version 'cerulean'
game 'gta5'

description 'VR-Pawnshop'
version '1.0.0'

shared_scripts { 
	'@vr-core/import.lua',
	'config.lua'
}

server_script 'server/main.lua'

client_scripts {
	'client/main.lua',
	'client/melt.lua'
}