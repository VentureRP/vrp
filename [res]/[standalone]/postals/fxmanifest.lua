fx_version 'cerulean'
games { 'gta5' }
lua54 "yes"

author 'zfbx & DevBlocky'
description 'This script displays the nearest postal next to map, and allows you to navigate to specific postal codes'
version '1.5.2'
url 'https://github.com/DevBlocky/nearest-postal'

client_script 'client.lua'

file('ocrp-postals.json')
postal_file('ocrp-postals.json')