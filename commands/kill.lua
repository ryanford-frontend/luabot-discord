local Pattern = require('utils/pattern')
local urlencode = require('querystring').urlencode
local concat = table.concat
local sf = string.format
local sub = string.sub
local unpack = table.unpack
local config = require('../config.lua')
local admin_role = config.admin_role

local kill = {
   _SIGNATURE = '!kill',
   _DESCRIPTION = 'Shutdown Luabot (mods only)',
   _ROLE = admin_role
}
local mt = {__call = function(_, message, commands)
   local help_pattern = Pattern:new{
      name = 'kill',
      prefix = '!',
   }

   if not message.guild then return end

   local matches = help_pattern:match(message.content) or {}

   if #matches > 0 then
      local member = message.guild:getMember(message.author)
      if member and member:hasRole(admin_role) then
         message.channel:send('Shutting down...')
         error('KILLED!!!\n' .. message.author.username .. ': ' .. message.content)
      end
   end
end}

mt.__index = mt

return setmetatable(kill, mt)
