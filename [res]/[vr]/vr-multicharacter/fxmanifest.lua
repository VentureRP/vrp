fx_version 'cerulean'
game 'gta5'

description 'VR-Multicharacter'
version '1.0.0'

ui_page 'html/index.html'

shared_script '@vr-core/import.lua'
client_script 'client/main.lua'
server_script 'server/main.lua'

files {
    'html/index.html',
    'html/style.css',
    'html/reset.css',
    'html/script.js'
}

dependencies {
    'vr-core',
    'vr-spawn'
}