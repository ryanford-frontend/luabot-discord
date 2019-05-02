local commands = {}
local commands_mt = {}

function commands_mt.add(self, name)
   self[name] = require('../commands/' .. name)
end

function commands_mt.run(self, message)
   for _, command in pairs(self) do
      command(message, self)
   end
end

commands_mt.__index = commands_mt

return setmetatable(commands, commands_mt)

