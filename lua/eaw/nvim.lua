local Log = require("eaw.log")

---@class cellwidths.nvim.Uv
---@field fs_close fun(fd: number): nil
---@field fs_open fun(path: string, flags: string, mode: integer): integer|nil
---@field fs_write fun(fd: number, data: string): integer|nil

---@class eaw.nvim.Nvim
---@field uv cellwidths.nvim.Uv
---@field log eaw.log.Log
local Nvim = {}

---@return eaw.nvim.Nvim
Nvim.new = function()
  return {
    uv = {
      fs_close = vim.loop.fs_close,
      fs_open = vim.loop.fs_open,
      fs_write = vim.loop.fs_write,
    },
    log = Log.new(vim.notify),
  }
end

return Nvim
