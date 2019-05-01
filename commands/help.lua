local Pattern = require('utils/pattern')
local urlencode = require('querystring').urlencode
local concat = table.concat
local sf = string.format
local unpack = table.unpack

local help = {}
local mt = {__call = function(_, message)
   local help_pattern = Pattern:new{
      name = 'help',
      prefix = '!',
      args = 1,
   }

   local matches = help_pattern:match(message.content) or {}

   for _, match in ipairs(matches) do
      local mentions, queries = unpack(match)
      for i,v in ipairs(queries) do queries[i] = v ~= '' and urlencode(v) or nil end
      local response = sf(
         '%s <https://devdocs.io/%s>',
         concat(mentions, ' '),
         #queries > 0 and '#q=' .. concat(queries, '%20') or ''
      )
      message.channel:send(response)
   end
end}

mt.__index = mt

return setmetatable(help, mt)
