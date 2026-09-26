local xsl = nitrogen.text()
local xml = nitrogen.text(-1)
local out, err, code = nitrogen.run("xsltproc", { nitrogen.temp_file(xsl), "-" }, xml)
if code ~= 0 then error(err) end
nitrogen.open_text(out, "result.xml")
