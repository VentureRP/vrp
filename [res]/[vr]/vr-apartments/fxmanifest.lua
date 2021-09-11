fx_version 'cerulean'
game 'gta5'

description 'VR-Apartments'
version '1.0.0'

shared_scripts { 
	'@vr-core/import.lua',
	'config.lua'
}

server_script 'server/main.lua'

client_scripts {
	'client/main.lua',
	'client/gui.lua'
}

dependencies {
	'vr-core',
	'vr-interior',
	'vr-clothing',
	'vr-weathersync'
}