local popen = io.popen
local load_commands = {}
local mt = {__call = function(_, dir)
   local commands = {}
   local files = popen('ls ' .. dir)

   for command in files:lines() do
      commands[#commands + 1] = loadfile(dir .. '/' .. command)
   end

   return commands
end}

mt.__index = mt

return setmetatable(load_commands, mt)
