fx_version 'cerulean'

game 'gta5'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

ui_page "html/index.html"

files{
    'html/index.html',
    'html/images/*.png',
    'html/images/*.jpg',
    'html/*.mp3',
    'html/script.js',
    'html/style.css',
    'html/fonts/*.woff',
    'html/fonts/*.woff2',
    'html/fonts/*.otf',
    'html/fonts/*.ttf'
}

client_script '@esx_libraries/client/debug.lua'

client_script "@Greek_ac/client/injections.lua"

server_script '@optimizer/server/optimize.lua'
server_script "@Protector/Server/injection.lua"