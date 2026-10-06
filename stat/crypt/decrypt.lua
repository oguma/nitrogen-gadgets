local key, body = nitrogen.text():match("^([^\r\n]*)\r?\n?(.*)$")
if key == "" then
  nitrogen.message("Put the passphrase on the first line.")
  return
end

local hex = body:gsub("%s", "")
if hex:find("[^%x]") or #hex % 2 == 1 then
  nitrogen.message("Not encrypted text.")
  return
end

local out = {}
for i = 1, #hex / 2 do
  local k = key:byte((i - 1) % #key + 1)
  out[i] = string.char(tonumber(hex:sub(2 * i - 1, 2 * i), 16) ~ k)
end

nitrogen.set_text(table.concat(out))
