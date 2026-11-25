---@class eaw
---@field get fun(char: string, opts: table?): string
---@field version string Unicode version of the bundled EastAsianWidth.txt

local Eaw = require "eaw.main"
local Nvim = require "eaw.nvim"
local eaw = Eaw.new(Nvim.new())

return setmetatable({ eaw = eaw }, {
  __index = function(self, key)
    if key == "get" then
      return function(...)
        return eaw:get(...)
      end
    elseif key == "version" then
      return eaw.table.version
    end
    return function()
      eaw.nvim.log:error("unknown command: %s", key)
    end
  end,
}) --[[@as eaw]]
