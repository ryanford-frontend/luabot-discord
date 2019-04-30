local lpeg = require('lpeg')

local patterns = {}

local C = lpeg.C
local Cc = lpeg.Cc
local Ct = lpeg.Ct
local P = lpeg.P
local R = lpeg.R
local S = lpeg.S
local V = lpeg.V

local white = S(' \t\r\n')
local opt_space = white ^ 0
local space = white ^ 1
local mention = P {
   'mention',
   mention = (((1 - V'user') ^ 0 * space) + opt_space) * V'user',
   user = C(P'<@' * P'!' ^ -1 * R'09' ^ 1 * P'>') * space,
}
local command = opt_space * P'!docs' * (-(1 - (space + P';')))
local query = P{
   'arg',
   arg = opt_space * P';' * Cc('', '') + V'term' ^ -2,
   term = space * C(P(1 - (space + P';' + mention + command)) ^ 0) + Cc'',
}
local docs = Ct(mention ^ 0) * command * Ct(query)
local backtick = -P'\\' * P'`'
local inline_code = opt_space * backtick * (1 - backtick) ^ 0 * backtick
local block_start = backtick * P'`' * P'`' * S'\r\n'
local block_end = block_start
local codeblock = block_start * (1 - block_end) * 0 * block_end

patterns.docs = Ct(P{
    'message',
    message = ((inline_code + codeblock + V'not_docs' * space * Ct(docs)) + Ct(docs) + (V'not_docs' * (-docs + P'!docs' * space))) ^ 1 * -1,
    not_docs = opt_space * (1 - docs - inline_code) ^ 1,
 })

return patterns
