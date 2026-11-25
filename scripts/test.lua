-- Sanity checks for lua/eaw/generated.lua.
--
-- Usage:
--   nvim --clean --headless -l scripts/test.lua

local script_dir = vim.fs.dirname(vim.fs.normalize(debug.getinfo(1, "S").source:sub(2)))
vim.opt.runtimepath:prepend(vim.fs.normalize(vim.fs.joinpath(script_dir, "..")))

local eaw = require "eaw"
local failures = 0

local function check(name, got, expected, quiet)
  if got == expected then
    if quiet then
      return
    end
    print(("ok   %s"):format(name))
  else
    failures = failures + 1
    print(("FAIL %s: expected %s, got %s"):format(name, vim.inspect(expected), vim.inspect(got)))
  end
end

check("version", type(eaw.version) == "string" and eaw.version:match "^%d+%.%d+%.%d+$" ~= nil, true)

local cases = {
  { 0x0000, "N" }, -- <control>
  { 0x0041, "Na" }, -- LATIN CAPITAL LETTER A
  { 0x00A1, "A" }, -- INVERTED EXCLAMATION MARK
  { 0x00E0, "A" }, -- LATIN SMALL LETTER A WITH GRAVE (category "L&")
  { 0x0378, "N" }, -- unassigned
  { 0x3042, "W" }, -- HIRAGANA LETTER A
  { 0x4E00, "W" }, -- CJK UNIFIED IDEOGRAPH-4E00
  { 0xFF21, "F" }, -- FULLWIDTH LATIN CAPITAL LETTER A
  { 0xFF71, "H" }, -- HALFWIDTH KATAKANA LETTER A
  { 0x1F600, "W" }, -- GRINNING FACE
  { 0x10FFFD, "A" }, -- <private-use-10FFFD>
}
for _, case in ipairs(cases) do
  check(("U+%04X"):format(case[1]), eaw.get(vim.fn.nr2char(case[1])), case[2])
end

local detail = eaw.get("あ", { detail = true })
check("detail.pos_start", detail.pos_start <= 0x3042 and 0x3042 <= detail.pos_end, true)

local entries = require("eaw.generated").entries
check("entries are many", #entries > 2000, true)
local total = 0
for _, entry in ipairs(entries) do
  check(("count of U+%04X"):format(entry[1]), entry[2] - entry[1] + 1, entry[5], true)
  total = total + entry[5]
end
-- Every code point except unassigned ones is listed; that is well over 250,000.
check("total code points", total > 250000, true)

if failures > 0 then
  print(("%d failure(s)"):format(failures))
  os.exit(1)
end
