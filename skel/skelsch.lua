local skeleton = [[
<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron">

  <pattern>
    <rule context="item">
      <assert test="@id">An item must have an id.</assert>
    </rule>
  </pattern>

</schema>
]]

local ok, current = pcall(nitrogen.text)

if ok and current:match("^%s*$") then
  nitrogen.set_text(skeleton)
else
  nitrogen.open_text(skeleton, "data.sch")
end
