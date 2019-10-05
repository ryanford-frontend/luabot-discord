local discordia = require('discordia')
local client = discordia.Client()
local config = require('config')
local TOKEN = config.token
local coro_wrap = coroutine.wrap
local fs = require('coro-fs')
local scandir = fs.scandir
local commands = require('./utils/commands.lua')
local logger = discordia.Logger(3, '%Y-%m-%d %H:%m:%S', './discordia.log')

coro_wrap(function()
   for f in scandir('commands') do
      logger:log(3, 'Loading ' .. f.name)
      commands:add(f.name)
   end
end)()

client:on('ready', function()
   logger:log(3, 'Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
   commands:run(message)
end)

client:run(TOKEN)
