local text = nitrogen.text()
local path = nitrogen.file_name()

local SEP = "[/" .. string.char(92) .. "]"

local loc
for pi in text:gmatch("<%?xml%-model%s(.-)%?>") do
  local href = pi:match('href%s*=%s*"([^"]*)"') or pi:match("href%s*=%s*'([^']*)'")
  if href and (pi:find("schematron", 1, true) or href:match("%.sch$")) then
    loc = href
    break
  end
end

if not loc then
  nitrogen.message(
    "No Schematron schema is named in this document.\n\n" ..
    "Add this line under the XML declaration:\n" ..
    '<?xml-model href="rules.sch" type="application/xml" ' ..
    'schematypens="http://purl.oclc.org/dsdl/schematron"?>')
  return
end

local function is_absolute(p)
  return p:match("^%a:" .. SEP) or p:match("^" .. SEP) or p:match("^%a[%w+.-]*://")
end

local sch = loc
if not is_absolute(sch) then
  local dir = path and path:match("^(.*" .. SEP .. ")") or ""
  sch = dir .. sch
end

local home = nitrogen.dir() .. package.config:sub(1, 1) .. "sch"

local function xsl(name)
  return home .. package.config:sub(1, 1) .. name
end

local needed = {
  "iso_dsdl_include.xsl",
  "iso_abstract_expand.xsl",
  "iso_svrl_for_xslt1.xsl",
  "iso_schematron_skeleton_for_xslt1.xsl",
}

local base = "https://raw.githubusercontent.com/Schematron/schematron/master/trunk/schematron/code/"

for _, name in ipairs(needed) do
  local f = io.open(xsl(name))
  if not f then
    local urls = {}
    for i, n in ipairs(needed) do urls[i] = base .. n end
    nitrogen.open_text(
      "The ISO Schematron XSLT 1.0 files were not found.\n\n" ..
      "Download these four files and put them in\n" .. home .. "\n\n" ..
      table.concat(urls, "\n") .. "\n", "schematron.txt")
    return
  end
  f:close()
end

local report = nitrogen.temp_file([[
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
  <xsl:output method="text"/>
  <xsl:template match="/">
    <xsl:for-each select="//svrl:failed-assert | //svrl:successful-report">
      <xsl:value-of select="@location"/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="normalize-space(svrl:text)"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
]])

local function step(args, input)
  local out, err, code = nitrogen.run("xsltproc", args, input)
  if code == -1 then
    nitrogen.message(
      "xsltproc was not found.\n\n" ..
      "It comes with libxslt. Put it on PATH and run this gadget again.")
    return nil
  end
  if code ~= 0 then
    nitrogen.message(err ~= "" and err or ("xsltproc exited with " .. tostring(code) .. "."))
    return nil
  end
  return out
end

local s = step({ xsl("iso_dsdl_include.xsl"), sch })
s = s and step({ xsl("iso_abstract_expand.xsl"), "-" }, s)
s = s and step({ xsl("iso_svrl_for_xslt1.xsl"), "-" }, s)
s = s and step({ nitrogen.temp_file(s), "-" }, text)
s = s and step({ report, "-" }, s)
if not s then return end

local shown = path and path:match("([^/" .. string.char(92) .. "]+)$") or "untitled.xml"

if s:match("^%s*$") then
  nitrogen.message(shown .. " is valid against " .. loc .. ".")
else
  nitrogen.message(s)
end
