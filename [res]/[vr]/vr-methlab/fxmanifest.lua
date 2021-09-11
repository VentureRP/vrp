fx_version 'cerulean'
game 'gta5'

description 'VR-Methlab'
version '1.1.0'

ui_page 'html/index.html'

shared_scripts { 
	'@vr-core/import.lua',
	'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

server_exports {
    'GenerateRandomLab'
}