fx_version "cerulean"
game "gta5"
lua54 'yes'

author ".vincyxir"
description "menu for boosting fps"
version "1.0.1"

shared_scripts {
        '@ox_lib/init.lua',
	'config.lua'
}

client_scripts {
        'client/client.lua',
}

server_scripts {
	'server/version_check.lua',
}

ui_page 'web/index.html'

files {
	'web/index.html',
	'web/styles.css',
	'web/app.js',
}

dependencies {
	'ox_lib',
}
