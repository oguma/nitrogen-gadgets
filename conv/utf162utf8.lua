local path, folder = nitrogen.selected()

if not path or folder then
  nitrogen.message("Select a UTF-16 file in the project tree first.")
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
  for at = offset, math.min(#bytes, 4096), 2 do
    total = total + 1
    if bytes:byte(at) == 0 then zeros = zeros + 1 end
  end
  return total > 0 and zeros / total > 0.3
end

local big, i
if bytes:sub(1, 4) == "\255\254\0\0" then
  nitrogen.message("This is UTF-32, not UTF-16.")
  return
elseif bytes:sub(1, 2) == "\254\255" then
  big, i = true, 3
elseif bytes:sub(1, 2) == "\255\254" then
  big, i = false, 3
elseif looks_utf16(1) then
  big, i = true, 1
elseif looks_utf16(2) then
  big, i = false, 1
else
  nitrogen.message("This does not look like UTF-16.")
  return
end

local function unit(at)
  local a, b = bytes:byte(at, at + 1)
  if not b then return nil end
  if big then return a * 256 + b end
  return b * 256 + a
end

local out = {}
while i <= #bytes do
  local u = unit(i)
  if not u then break end
  i = i + 2
  if u >= 0xD800 and u <= 0xDBFF then
    local lo = unit(i)
    if lo and lo >= 0xDC00 and lo <= 0xDFFF then
      u = 0x10000 + (u - 0xD800) * 0x400 + (lo - 0xDC00)
      i = i + 2
    else
      u = 0xFFFD
    end
  elseif u >= 0xDC00 and u <= 0xDFFF then
    u = 0xFFFD
  end
  out[#out + 1] = utf8.char(u)
end

nitrogen.open_text(table.concat(out), path:match("[^\\/]+$"))
