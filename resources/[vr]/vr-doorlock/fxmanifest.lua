fx_version 'cerulean'
game 'gta5'

description 'VR-Doorlock'
version '1.0.0'

shared_scripts {
	'config.lua',
	'@vr-core/import.lua'
}


server_script 'server/main.lua'
client_script 'client/main.lua'
