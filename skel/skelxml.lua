local skeleton = [[
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="data.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<?xml-model href="data.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<!DOCTYPE root SYSTEM "data.dtd">
<root xmlns:xi="http://www.w3.org/2001/XInclude"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:noNamespaceSchemaLocation="data.xsd">
  <xi:include href="part.xml"/>
  <item id="1">text</item>
</root>
]]

local ok, current = pcall(nitrogen.text)

if ok and current:match("^%s*$") then
  nitrogen.set_text(skeleton)
else
  nitrogen.open_text(skeleton, "data.xml")
end
