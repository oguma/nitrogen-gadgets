local text = nitrogen.text()
local path = nitrogen.file_name()

local SEP = "[/" .. string.char(92) .. "]"

local function attr(name)
  return text:match(name .. '%s*=%s*"([^"]*)"') or text:match(name .. "%s*=%s*'([^']*)'")
end

local loc = attr("noNamespaceSchemaLocation")
if not loc then
  local both = attr("[%w_]-:?schemaLocation")
  if both then
    local words = {}
    for w in both:gmatch("%S+") do words[#words + 1] = w end
    loc = words[2]
  end
end

if not loc then
  nitrogen.message(
    "No schema is named in this document.\n\n" ..
    'Add xsi:noNamespaceSchemaLocation="catalog.xsd" to the root element, ' ..
    'with xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance".')
  return
end

local function is_absolute(p)
  return p:match("^%a:" .. SEP) or p:match("^" .. SEP) or p:match("^%a[%w+.-]*://")
end

local xsd = loc
if not is_absolute(xsd) then
  local dir = path and path:match("^(.*" .. SEP .. ")") or ""
  xsd = dir .. xsd
end

local tmp = nitrogen.temp_file(text)
local out, err, code = nitrogen.run("xmllint", { "--noout", "--schema", xsd, tmp })

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
