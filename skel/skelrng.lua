local skeleton = [[
<?xml version="1.0" encoding="UTF-8"?>
<grammar xmlns="http://relaxng.org/ns/structure/1.0"
         datatypeLibrary="http://www.w3.org/2001/XMLSchema-datatypes">

  <start>
    <element name="root">
      <zeroOrMore>
        <element name="item">
          <attribute name="id"><data type="integer"/></attribute>
          <text/>
        </element>
      </zeroOrMore>
    </element>
  </start>

</grammar>
]]

local ok, current = pcall(nitrogen.text)

if ok and current:match("^%s*$") then
  nitrogen.set_text(skeleton)
else
  nitrogen.open_text(skeleton, "data.rng")
end
