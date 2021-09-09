fx_version 'cerulean'
game 'gta5'

description 'VR-Vineyard'
version '1.0.0'

shared_scripts { 
	'@vr-core/import.lua',
	'config.lua'
}

server_script 'server.lua'
client_script 'client.lua'