---@alias Entry integer[]

---@alias Dumped Entry[]

---@class eaw.table.Entry
---@field pos_start integer
---@filed pos_end integer
---@field sign string
---@field comment string

local lib_dir = (function()
  local source = debug.getinfo(2, "S").source
  local dir = source:gsub("@(.*)%/[^%/]+$", "%1")
  return dir
end)()

---@class eaw.table.Table
---@field nvim eaw.nvim.Nvim
---@field table Dumped
local Table = {}

---@param nvim eaw.nvim.Nvim
---@param tbl Dumped?
---@return eaw.table.Table
Table.new = function(nvim, tbl)
  local self = setmetatable({ nvim = nvim }, { __index = Table })
  tbl = tbl or self:load()
  if not tbl then
    error "dumped table not found"
  end
  self.table = tbl
  return self
end

---@return string
function Table:filename()
  self._filename = self._filename or lib_dir .. "/generated.lua"
  return self._filename
end

---@return Dumped?
function Table:load()
  local ok, code = pcall(require, "eaw.generated")
  if not ok then
    self.nvim.log:trace "requiring failed"
    return
  end
  local f = loadstring(code)
  if not f then
    self.nvim.log:error "loadfile() failed"
    return nil
  end
  local tbl = f()
  if type(tbl) ~= "table" then
    self.nvim.log:error "result from loadfile() is not a table"
    return nil
  end
  return tbl
end

---@return nil
function Table:save()
  local fd = self.nvim.uv.fs_open(self:filename(), "w", tonumber("644", 8))
  if not fd then
    self.nvim.log:error("cannot open file: " .. self:filename())
    return
  end
  local f, err = load("return " .. vim.inspect(self.table))
  if not f then
    self.nvim.log:error("cannot load: " .. err)
    return
  end
  local code = string.dump(f, true)
  local result = self.nvim.uv.fs_write(fd, "return " .. vim.inspect(code))
  if type(result) ~= "number" then
    self.nvim.log:error("cannot write code: " .. tostring(result))
    return
  end
  self.nvim.log:info "saved successfully"
end

---@param char string
---@return eaw.table.Entry
function Table:search(char)
  local code = vim.fn.char2nr(char)
  local entry = self:binary(code, 1, #self.table)
  return {
    pos_start = entry[1],
    pos_end = entry[2],
    sign = entry[3],
    comment = entry[4],
  }
end

---@param code integer
---@param pos_start integer
---@param pos_end integer
---@return Entry
function Table:binary(code, pos_start, pos_end)
  local s, e = self.table[pos_start], self.table[pos_end]
  if s[1] > code then
    return self:binary(code, 0, pos_start)
  elseif s[1] <= code and s[2] >= code then
    return s
  elseif s[2] < code and e[1] > code then
    local center = pos_start + math.floor((pos_end - pos_start) / 2)
    local c = self.table[center]
    if c[1] > code then
      return self:binary(code, pos_start, center)
    elseif c[1] <= code and c[2] >= code then
      return c
    else
      return self:binary(code, center, pos_end)
    end
  elseif e[1] <= code and e[2] >= code then
    return e
  end
  return { 0, 0, "U", "Unknown" }
end

return Table
