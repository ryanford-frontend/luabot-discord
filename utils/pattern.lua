local lpeg = require('lpeg')
local C = lpeg.C
local Cc = lpeg.Cc
local Ct = lpeg.Ct
local P = lpeg.P
local R = lpeg.R
local S = lpeg.S
local V = lpeg.V

local pattern = {}
local mt = {__call = function(_, options)
   if not options then 
      return nil, 'options table or command name is required'
   elseif type(options) == 'string' then
      options = { name = options }
   elseif type(options) ~= 'table' then
      return nil, 'constructor requires a command name or options table'
   elseif not options.name then
      return nil, 'name field required in options table'
   end

   local prefix = options.prefix or '!'
   local name = options.name
   local signature = prefix .. name
   local white = S(' \t\r\n')
   local opt_space = white ^ 0
   local space = white ^ 1
   local mention = P {
      'mention',
      mention = (((1 - V'user') ^ 0 * space) + opt_space) * V'user',
      user = C(P'<@' * P'!' ^ -1 * R'09' ^ 1 * P'>') * space,
   }
   local command = opt_space * P(signature) * (-(1 - (space + P';')))
   local query = P{
      'arg',
      arg = opt_space * P';' * Cc('', '') + (function(n) return n and V'term' ^ -n or V'term' end)(options.args),
      term = space * C(P(1 - (space + P';' + mention + command)) ^ 0) + Cc'',
   }
   local full_command = Ct(mention ^ 0) * command * Ct(query)
   local backtick = -P'\\' * P'`'
   local inline_code = opt_space * backtick * (1 - backtick) ^ 0 * backtick
   local block_start = backtick * P'`' * P'`' * S'\r\n'
   local block_end = block_start
   local codeblock = block_start * (1 - block_end) * 0 * block_end

   return Ct(P{
      'message',
      message = ((inline_code + codeblock + V'not_command' * space * Ct(full_command)) + Ct(full_command) + (V'not_command' * (-full_command + P(signature) * space))) ^ 1 * -1,
      not_command = opt_space * (1 - full_command - inline_code) ^ 1,
   })
end}

mt.__index = mt

-- sugar for the OO style calls
function pattern.new(self, options) return self(options) end

return setmetatable(pattern, mt)
