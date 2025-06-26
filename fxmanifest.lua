fx_version "cerulean"
game "gta5"
lua54 "yes"

name "mnr_cayo"
description "Cayo Perico loader script"
author "IlMelons"
version "1.0.3"
repository "https://github.com/Monarch-Development/mnr_cayo"

this_is_a_map "yes"

shared_scripts {
    "@ox_lib/init.lua",
}

client_scripts {
    "client/*.lua",
}

server_scripts {
    "server/*.lua",
}

files {
    "data/*.lua",
}
