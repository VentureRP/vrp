fx_version 'cerulean'
game 'gta5'

description 'VR-TaxiJob'
version '1.0.0'

ui_page 'html/meter.html'

shared_scripts { 
	'@vr-core/import.lua',
	'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/gui.lua'
}

server_script 'server/main.lua'

files {
    'html/meter.css',
    'html/meter.html',
    'html/meter.js',
    'html/reset.css',
    'html/g5-meter.png'
}