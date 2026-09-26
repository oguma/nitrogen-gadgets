local s = nitrogen.text()
local chars = utf8.len(s) or #s
local lines = select(2, s:gsub("\n", "")) + 1

nitrogen.message(string.format("%d characters\n%d bytes\n%d lines", chars, #s, lines))
