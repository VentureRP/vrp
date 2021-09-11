fx_version 'cerulean'
game 'gta5'

description 'VR-CommandBinding'
version '1.0.0'

ui_page 'html/index.html'

shared_script '@vr-core/import.lua'
server_script 'server/main.lua'
client_script 'client/main.lua'

files {
	'html/*'
}