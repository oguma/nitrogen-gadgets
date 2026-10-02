local text = nitrogen.text()
local path = nitrogen.file_name()

local SEP = "[/" .. string.char(92) .. "]"

if not text:find("<!DOCTYPE", 1, true) then
  nitrogen.message(
    "No DTD is named in this document.\n\n" ..
    "Add this line under the XML declaration:\n" ..
    '<!DOCTYPE catalog SYSTEM "catalog.dtd">')
  return
end

local dir = path and path:match("^(.*)" .. SEP) or "."

local tmp = nitrogen.temp_file(text)
local out, err, code = nitrogen.run("xmllint", { "--noout", "--valid", "--path", dir, tmp })

if code == -1 then
  nitrogen.message(
    "xmllint was not found.\n\n" ..
    "It comes with libxml2. Put it on PATH and run this gadget again.")
  return
end

local shown = path and path:match("([^/" .. string.char(92) .. "]+)$") or "untitled.xml"
local report = (err ~= "" and err or out):gsub(tmp:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%0"), shown)

if code == 0 then
  nitrogen.message(shown .. " is valid against its DTD.")
else
  nitrogen.message(report ~= "" and report or
    ("xmllint exited with " .. tostring(code) .. "."))
end
