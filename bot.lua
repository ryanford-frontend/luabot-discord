local discordia = require('discordia')
local client = discordia.Client()
local config = require('config')
local TOKEN = config.token
local concat = table.concat
local sf = string.format
local unpack = table.unpack
local docs = require('patterns.docs')

client:on('ready', function()
   print('Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
   if message.content == '!ping' then
      message.channel:send('Pong!')
   end
end)

client:on('messageCreate', function(message)
   local matches = docs:match(message.content) or {}
   if #matches == 0 then return end
   
   for _, match in ipairs(matches) do
      local mentions, queries = unpack(match)
      for i,v in ipairs(queries) do queries[i] = v ~= '' and v or nil end
      local response = sf(
         '%s <https://devdocs.io/%s>',
         concat(mentions, ' '),
         #queries > 0 and '#q=' .. concat(queries, '%20') or ''
      )
      message.channel:send(response)
   end
end)

client:run(TOKEN)
