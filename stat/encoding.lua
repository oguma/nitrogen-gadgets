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

local function starts(prefix)
  return bytes:sub(1, #prefix) == prefix
end

local function looks_utf16(offset)
  local zeros, total = 0, 0
  for i = offset, math.min(#bytes, 4096), 2 do
    total = total + 1
    if bytes:byte(i) == 0 then zeros = zeros + 1 end
  end
  return total > 0 and zeros / total > 0.3
end

local function iso2022_jp()
  return bytes:find("\27$B", 1, true) or bytes:find("\27$@", 1, true)
      or bytes:find("\27(J", 1, true)
end

local function euc_jp_plausible()
  local i, run, best, n = 1, 0, 0, #bytes
  while i <= n do
    local b = bytes:byte(i)
    if b < 0x80 then
      i, run = i + 1, 0
    elseif b >= 0xA1 and b <= 0xFE then
      local t = bytes:byte(i + 1)
      if not t or t < 0xA1 or t > 0xFE then return 0 end
      i, run = i + 2, run + 1
    elseif b == 0x8E then
      local t = bytes:byte(i + 1)
      if not t or t < 0xA1 or t > 0xDF then return 0 end
      i, run = i + 2, run + 1
    else
      return 0
    end
    if run > best then best = run end
  end
  return best
end

-- A run of two adjacent double-byte characters is what separates Japanese
-- from Latin-1: an accented letter sits alone between ASCII, but a word in
-- kana or kanji does not.
local function sjis_plausible()
  local i, run, best, n = 1, 0, 0, #bytes
  while i <= n do
    local b = bytes:byte(i)
    if b < 0x80 then
      i, run = i + 1, 0
    elseif b >= 0xA1 and b <= 0xDF then
      i, run = i + 1, run + 1
    elseif (b >= 0x81 and b <= 0x9F) or (b >= 0xE0 and b <= 0xFC) then
      local t = bytes:byte(i + 1)
      if not t then return 0 end
      if not ((t >= 0x40 and t <= 0x7E) or (t >= 0x80 and t <= 0xFC)) then
        return 0
      end
      i, run = i + 2, run + 1
    else
      return 0
    end
    if run > best then best = run end
  end
  return best
end

local name, note

if starts("\239\187\191") then
  name, note = "UTF-8 with BOM", "Nitrogen opens it without the BOM and puts it back when you save."
elseif starts("\255\254\0\0") then
  name, note = "UTF-32LE with BOM", "Nitrogen will not open this."
elseif starts("\255\254") then
  name, note = "UTF-16LE with BOM", "Nitrogen will not open this: it opens ASCII and UTF-8 only."
elseif starts("\254\255") then
  name, note = "UTF-16BE with BOM", "Nitrogen will not open this."
elseif #bytes == 0 then
  name, note = "empty", nil
elseif looks_utf16(1) then
  name, note = "UTF-16BE, no BOM", "Nitrogen will not open this."
elseif looks_utf16(2) then
  name, note = "UTF-16LE, no BOM", "Nitrogen will not open this."
else
  local ok, bad = utf8.len(bytes)
  if ok then
    if iso2022_jp() then
      name = "ISO-2022-JP"
      note = "7-bit, but Nitrogen will not open it: the escape sequences are not text."
    elseif ok == #bytes then
      name, note = "ASCII", "Plain 7-bit, so every encoding below agrees."
    else
      name, note = "UTF-8", nil
    end
  else
    local lost = ("Not valid UTF-8 (first bad byte at %d). Nitrogen will not open it."):format(bad)
    if euc_jp_plausible() >= 2 then
      name, note = "EUC-JP", lost
    elseif sjis_plausible() >= 2 then
      name, note = "Shift_JIS / CP932", lost
    else
      name = "8-bit, not UTF-8"
      note = ("First bad byte at %d. Latin-1, CP1252 or another code page. Nitrogen will not open it."):format(bad)
    end
  end
end

local out = { name, ("%d bytes"):format(#bytes) }
if note then out[#out + 1] = note end
nitrogen.message(table.concat(out, "\n"))
