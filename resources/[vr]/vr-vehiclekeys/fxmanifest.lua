fx_version 'cerulean'
game 'gta5'

description 'VR-VehicleKeys'
version '1.0.0'

shared_script '@vr-core/import.lua'
server_script 'server/main.lua'

client_script {
    'client/main.lua',
    'config.lua'
}

dependencies {
    'vr-core',
    'vr-skillbar'
}