fx_version 'cerulean'
game 'gta5'

description 'VR-Clothing'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts { 
	'@vr-core/import.lua',
	'config.lua'
}

server_script 'server/main.lua'
client_script 'client/main.lua'

files {
	'html/index.html',
	'html/style.css',
	'html/reset.css',
	'html/script.js'
}

dependencies {
	'vr-core'
}