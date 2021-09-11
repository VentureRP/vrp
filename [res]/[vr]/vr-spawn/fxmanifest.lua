fx_version 'cerulean'
game 'gta5'

description 'VR-Spawn'
version '1.0.0'

shared_scripts {
	'config.lua',
	'@vr-core/import.lua',
	'@vr-houses/config.lua',
	'@vr-apartments/config.lua'
}

client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/style.css',
	'html/script.js',
	'html/reset.css'
}

dependencies {
	'vr-core',
	'vr-houses',
	'vr-interior',
	'vr-apartments'
}