---@class eaw
---@field get fun(char: string, opts: table?): string

local Eaw = require "eaw.main"
local Nvim = require "eaw.nvim"
local eaw = Eaw.new(Nvim.new())

return setmetatable({ eaw = eaw }, {
  __index = function(self, key)
    if key == "get" then
      return function(...)
        return eaw:get(...)
      end
    end
    return function()
      eaw.nvim.log:error("unknown command: %s", key)
    end
  end,
}) --[[@as eaw]]
