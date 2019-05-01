local discordia = require('discordia')
local client = discordia.Client()
local config = require('config')
local TOKEN = config.token
local coro_wrap = coroutine.wrap
local fs = require('coro-fs')
local scandir = fs.scandir

local commands = {}

coro_wrap(function()
   for f in scandir('commands') do
      print('Loading ' .. f.name)
      local command = require('./commands/' .. f.name)
      commands[#commands + 1] = command
   end
end)()

client:on('ready', function()
   print('Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
   for _, command in ipairs(commands) do
      command(message)
   end
end)

client:run(TOKEN)
