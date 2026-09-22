local path = nitrogen.file_name()

if not path then
  nitrogen.message("Save the file first: this gadget reads the bytes on disk.")
  return
end

local f, err = io.open(path, "rb")
if not f then
  nitrogen.message("Cannot read the file.\n" .. tostring(err))
  return
end
local bytes = f:read("a")
f:close()

local function looks_utf16(offset)
  local zeros, total = 0, 0
  for i = offset, math.min(#bytes, 4096), 2 do
    total = total + 1
    if bytes:byte(i) == 0 then zeros = zeros + 1 end
  end
  return total > 0 and zeros / total > 0.3
end

local cr, lf = "\r", "\n"
local width = "bytes"

if bytes:sub(1, 2) == "\255\254" then
  cr, lf, width = "\r\0", "\n\0", "UTF-16LE"
elseif bytes:sub(1, 2) == "\254\255" then
  cr, lf, width = "\0\r", "\0\n", "UTF-16BE"
elseif looks_utf16(1) then
  cr, lf, width = "\0\r", "\0\n", "UTF-16BE"
elseif looks_utf16(2) then
  cr, lf, width = "\r\0", "\n\0", "UTF-16LE"
end

local function count(needle)
  local n, i = 0, 1
  while true do
    local at = bytes:find(needle, i, true)
    if not at then return n end
    n = n + 1
    i = at + #needle
  end
end

local crlf = count(cr .. lf)
local lone_lf = count(lf) - crlf
local lone_cr = count(cr) - crlf
local total = crlf + lone_lf + lone_cr

if total == 0 then
  nitrogen.message("No line break at all (" .. width .. ").")
  return
end

local kinds = {}
if crlf > 0 then kinds[#kinds + 1] = { "CRLF", crlf } end
if lone_lf > 0 then kinds[#kinds + 1] = { "LF", lone_lf } end
if lone_cr > 0 then kinds[#kinds + 1] = { "CR", lone_cr } end

table.sort(kinds, function(a, b) return a[2] > b[2] end)

local out = {}
for _, k in ipairs(kinds) do
  out[#out + 1] = ("%-4s %6d  %3d%%"):format(k[1], k[2], math.floor(k[2] / total * 100 + 0.5))
end

if #kinds > 1 then
  out[#out + 1] = ""
  out[#out + 1] = ("Mixed. Nitrogen saves every line as %s, the majority."):format(kinds[1][1])
end

local tail = bytes:sub(- #lf)
if tail ~= lf and tail ~= cr then
  out[#out + 1] = ""
  out[#out + 1] = "No line break at the end of the file."
end

nitrogen.message(table.concat(out, "\n"))
