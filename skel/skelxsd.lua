local skeleton = [[
<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xs:element name="root">
  </xs:element>

</xs:schema>
]]

local ok, current = pcall(nitrogen.text)

if ok and current:match("^%s*$") then
  nitrogen.set_text(skeleton)
else
  nitrogen.open_text(skeleton, "data.xsd")
end
