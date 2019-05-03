local Pattern = require('utils/pattern')
local urlencode = require('querystring').urlencode
local concat = table.concat
local sf = string.format
local sub = string.sub
local unpack = table.unpack
local config = require('../config.lua')
local admin_role = config.admin_role

local help = {
   _SIGNATURE = '[mentions [, ...]] !help [, command]',
   _DESCRIPTION = 'Get usage info for Luabot',
}
local mt = {__call = function(_, message, commands)
   local help_pattern = Pattern:new{
      name = 'help',
      prefix = '!',
      args = 1,
   }

   local matches = help_pattern:match(message.content) or {}

   for _, match in ipairs(matches) do
      local member = message.guild:getMember(message.author)
      local mentions, queries = unpack(match)
      local query = queries[1]
      local command = commands[query .. '.lua']
      local response = concat(mentions, ' ') .. '\n```text\n'
      local template = '\n\nName: %s\nDescription: %s\nUsage: %s'

      if not command or query == '' then
         response = response .. 'Luabot is an opensource bot written in Lua\nSee the source at https://github.com/ryanford-frontend/luabot-discord'
         for name, info in pairs(commands) do
            local authorized = info._ROLE ~= admin_role or info._ROLE == admin_role and member:hasRole(admin_role)
            if authorized then
               response = response .. sf(template, name:sub(1, -5), info._DESCRIPTION, info._SIGNATURE)
            end
         end
         response = response .. '\n```'
         message.channel:send(response)
      else
         local authorized = command._ROLE ~= admin_role or command._ROLE == admin_role and member:hasRole(admin_role)
         if authorized then
            response = response .. sf(template, query, command._DESCRIPTION, concat({ command._SIGNATURE, command._HELP }, '\n\n'))
            response = response .. '\n```'
            message.channel:send(response)
         end
      end
   end
end}

mt.__index = mt

return setmetatable(help, mt)
