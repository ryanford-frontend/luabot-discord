local lpeg = require('lpeg')

local patterns = {}

local C = lpeg.C
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
   user = C(P'<@' * R'09' ^ 1 * P'>') * space,
}

local command = opt_space * P'!docs'
local query = P {
   'arg',
   arg = V'term' ^ -2,
   term = opt_space * C(P(1 - (space + P';')) ^ 0),
}

local docs = Ct(mention ^ 0) * command * Ct(query)

patterns.docs = Ct(P {
    'message',
    message = ((V'not_docs' * space * Ct(docs)) + Ct(docs) + (V'not_docs' * (-docs))) ^ 1 * -1,
    not_docs = opt_space * (1 - docs) ^ 1,
 })

return patterns
