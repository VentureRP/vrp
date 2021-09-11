fx_version 'cerulean'
game 'gta5'

description 'VR-Scrapyard'
version '1.0.0'

shared_scripts { 
	'@vr-core/import.lua',
	'config.lua'
}

server_script 'server/main.lua'
client_script 'client/main.lua'