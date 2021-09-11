fx_version 'cerulean'
game 'gta5'

description 'VR-HUD'
version '2.0.0'

shared_scripts {
    'config.lua',
	'@vr-core/import.lua'
}

client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/styles.css',
	'html/app.js'
}