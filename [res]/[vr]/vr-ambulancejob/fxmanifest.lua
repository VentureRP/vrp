fx_version 'cerulean'
game 'gta5'

description 'VR-AmbulanceJob'
version '1.0.0'

shared_scripts { 
	'@vr-core/import.lua',
	'config.lua'
}

client_scripts {
	'client/main.lua',
	'client/wounding.lua',
	'client/laststand.lua',
	'client/job.lua',
	'client/dead.lua',
	'client/gui.lua',
}

server_script 'server/main.lua'
