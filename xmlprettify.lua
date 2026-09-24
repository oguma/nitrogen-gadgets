local text = nitrogen.text()

local out, err, code = nitrogen.run("xmllint", { "--format", "--encode", "UTF-8", "-" }, text)

if code == -1 then
  nitrogen.message(
    "xmllint was not found.\n\n" ..
    "It comes with libxml2. Put it on PATH and run this gadget again.")
  return
end

if code ~= 0 then
  nitrogen.message(err ~= "" and err or ("xmllint exited with " .. tostring(code) .. "."))
  return
end

if not text:match("^%s*<%?xml") then
  out = out:gsub("^<%?xml[^\n]*\n", "")
end

nitrogen.set_text(out)
