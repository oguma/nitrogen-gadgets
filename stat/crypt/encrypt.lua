local key, body = nitrogen.text():match("^([^\r\n]*)\r?\n?(.*)$")
if key == "" then
  nitrogen.message("Put the passphrase on the first line.")
  return
end

local out, line = {}, {}
for i = 1, #body do
  local k = key:byte((i - 1) % #key + 1)
  line[#line + 1] = string.format("%02x", body:byte(i) ~ k)
  if #line == 32 then
    out[#out + 1] = table.concat(line)
    line = {}
  end
end
if #line > 0 then out[#out + 1] = table.concat(line) end

nitrogen.set_text(table.concat(out, "\n") .. "\n")
