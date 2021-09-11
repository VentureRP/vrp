fx_version 'cerulean'
game 'gta5'

description 'VR-Prison'
version '1.0.0'

shared_scripts { 
	'@vr-core/import.lua',
	'config.lua'
}

client_scripts {
	'client/main.lua',
	'client/jobs.lua',
	'client/prisonbreak.lua'
}

server_script 'server/main.lua'