local skeleton = [[
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="document.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:noNamespaceSchemaLocation="document.xsd">
  <item id="1">text</item>
</root>
]]

local ok, current = pcall(nitrogen.text)

if ok and current:match("^%s*$") then
  nitrogen.set_text(skeleton)
else
  nitrogen.open_text(skeleton, "document.xml")
end
