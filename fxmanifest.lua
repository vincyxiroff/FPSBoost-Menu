fx_version "cerulean"
game "gta5"

author "FPSBoost-MENU"
description "menu for boosting fps"
version "1.0.0"

shared_scripts {
        '@ox_lib/init.lua',
	'config.lua'
}

client_scripts {
        'client/client.lua',
}

dependencies {
	'ox_lib',
}
