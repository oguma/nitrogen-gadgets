local skeleton = [[
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- add templates here; they override the copy above -->

</xsl:stylesheet>
]]

local ok, current = pcall(nitrogen.text)

if ok and current:match("^%s*$") then
  nitrogen.set_text(skeleton)
else
  nitrogen.open_text(skeleton, "transform.xsl")
end
