local Pattern = require('utils/pattern')
local urlencode = require('querystring').urlencode
local concat = table.concat
local sf = string.format
local unpack = table.unpack

local man = {
   _SIGNATURE = '[mentions [, ...]] !man [, query]',
   _DESCRIPTION = 'Search for Linux manpages',
}
local mt = {__call = function(_, message)
   local man_pattern = Pattern:new{
      name = 'man',
      prefix = '!',
      args = 1,
   }

   local matches = man_pattern:match(message.content) or {}

   for _, match in ipairs(matches) do
      local mentions, queries = unpack(match)
      local query = queries[1]
      query = query and urlencode(query) or ''
      local response = sf(
         '%s <https://linux.die.net/man/1/%s>',
         concat(mentions, ' '),
         query
      )
      message.channel:send(response)
   end
end}

mt.__index = mt

return setmetatable(man, mt)
