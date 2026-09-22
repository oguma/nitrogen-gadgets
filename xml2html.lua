local xsl = nitrogen.temp_file([[
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <html>
      <body>
        <h1><xsl:value-of select="name(*)"/></h1>
        <ul><xsl:apply-templates select="*"/></ul>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="*">
    <li>
      <b><xsl:value-of select="name()"/></b>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="text()"/>
      <xsl:if test="*">
        <ul><xsl:apply-templates select="*"/></ul>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match="@*">
    <i><xsl:value-of select="name()"/>=<xsl:value-of select="."/></i>
  </xsl:template>

</xsl:stylesheet>
]])

local out, err, code = nitrogen.run("xsltproc", { xsl, "-" }, nitrogen.text())

if code ~= 0 then
  nitrogen.message(err .. "\n\nxsltproc comes with libxslt.")
  return
end

nitrogen.open_text(out, "result.html")
