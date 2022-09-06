# eaw.nvim

Yet another plugin for East Asian Width characters.

## What's this?

You can get info for characters about [EastAsianWidth.txt][].

[EastAsianWidth.txt]: http://www.unicode.org/Public/UCD/latest/ucd/EastAsianWidth.txt

***still developing***

```lua
local eaw = require "eaw"

eaw.get "あ"  ---> "W"

eaw.get("あ", { detail = true })
---> {
--     comment = "HIRAGANA LETTER SMALL A..HIRAGANA LETTER SMALL KE",
--     count = 86,
--     generator_factory = "Lo",
--     pos_end = 12438,
--     pos_start = 12353,
--     sign = "W"
--   }
```
