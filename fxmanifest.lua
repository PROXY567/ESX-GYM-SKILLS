
lua54 "yes" 

fx_version 'cerulean'
game 'gta5'
description 'Proxy Skill System ESX - steroids, gym, SQL, anti-spam'
author 'Proxy'
version '1.0'
shared_scripts {
  'config/config.lua'
}
client_scripts {
  'client/main.lua'
}
server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/main.lua'
}
