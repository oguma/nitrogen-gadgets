local text = nitrogen.text()
local path = nitrogen.file_name()

local SEP = "[/" .. string.char(92) .. "]"

local loc
for pi in text:gmatch("<%?xml%-model%s(.-)%?>") do
  local href = pi:match('href%s*=%s*"([^"]*)"') or pi:match("href%s*=%s*'([^']*)'")
  if href and (pi:find("relaxng.org/ns/structure", 1, true) or href:match("%.rng$")) then
    loc = href
    break
  end
end

if not loc then
  nitrogen.message(
    "No RELAX NG schema is named in this document.\n\n" ..
    "Add this line under the XML declaration:\n" ..
    '<?xml-model href="catalog.rng" type="application/xml" ' ..
    'schematypens="http://relaxng.org/ns/structure/1.0"?>')
  return
end

if loc:match("%.rnc$") then
  nitrogen.message(
    "xmllint does not read the compact syntax (.rnc).\n\n" ..
    "Convert it to .rng first, for example with trang.")
  return
end

local function is_absolute(p)
  return p:match("^%a:" .. SEP) or p:match("^" .. SEP) or p:match("^%a[%w+.-]*://")
end

local rng = loc
if not is_absolute(rng) then
  local dir = path and path:match("^(.*" .. SEP .. ")") or ""
  rng = dir .. rng
end

local tmp = nitrogen.temp_file(text)
local out, err, code = nitrogen.run("xmllint", { "--noout", "--relaxng", rng, tmp })

if code == -1 then
  nitrogen.message(
    "xmllint was not found.\n\n" ..
    "It comes with libxml2. Put it on PATH and run this gadget again.")
  return
end

local shown = path and path:match("([^/" .. string.char(92) .. "]+)$") or "untitled.xml"
local report = (err ~= "" and err or out):gsub(tmp:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%0"), shown)

if code == 0 then
  nitrogen.message(shown .. " is valid against " .. loc .. ".")
else
  nitrogen.message(report ~= "" and report or
    ("xmllint exited with " .. tostring(code) .. "."))
end
