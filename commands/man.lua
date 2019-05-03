local Pattern = require('utils/pattern')
local urlencode = require('querystring').urlencode
local concat = table.concat
local sf = string.format
local unpack = table.unpack

local man = {
   _SIGNATURE = '[mentions [, ...]] !man [, section or query [, subquery]]',
   _DESCRIPTION = 'Search for Linux manpages',
   _HELP = [[
The table below shows the section numbers of the manual  followed  by  the
types of pages they contain.

1   Executable programs or shell commands
2   System calls (functions provided by the kernel)
3   Library calls (functions within program libraries)
4   Special files (usually found in /dev)
5   File formats and conventions eg /etc/passwd
6   Games
7   Miscellaneous (including macro packages and conventions)
8   System administration commands (usually only for root)
]],
}
local mt = {__call = function(self, message)
   local man_pattern = Pattern:new{
      name = 'man',
      prefix = '!',
      args = 2,
   }

   local matches = man_pattern:match(message.content) or {}

   for _, match in ipairs(matches) do
      local mentions, queries = unpack(match)
      local query, subquery = unpack(queries)
      query = query ~= '' and query or nil
      local response = '<https://linux.die.net/'
      query = urlencode(query)
      subquery = urlencode(subquery)
      if tonumber(query) then
         response = sf('%sman/%s/%s>', response, query, subquery)
      elseif query then
         subquery = subquery ~= '' and subquery or nil
         response = sf('%ssearch/?q=%s>', '<https://www.die.net/', urlencode(concat({ query, subquery }, '+')))
      else
         response = sf('```text\n%s\n```', concat({ 'man - ' .. self._DESCRIPTION, 'Usage: ' .. self._SIGNATURE }, '\n\n'))
      end

      message.channel:send(response)
   end
end}

mt.__index = mt

return setmetatable(man, mt)
