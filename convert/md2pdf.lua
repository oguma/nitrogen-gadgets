local path = nitrogen.file_name()

if not path or not path:lower():match("%.md$") then
  nitrogen.message("Open a saved Markdown (.md) file first.")
  return
end

local dir = path:match("^(.*)[/" .. string.char(92) .. "]") or "."
local pdf = path:sub(1, -4) .. ".pdf"

local out, err, code = nitrogen.run("pandoc", {
  path, "-o", pdf,
  "--pdf-engine=typst",
  "--resource-path=" .. dir,
  "-V", "mainfont=Segoe UI",
})

if code == -1 then
  nitrogen.message(
    "pandoc was not found.\n\n" ..
    "Install pandoc and typst, put them on PATH, and run this gadget again.")
  return
end

if code ~= 0 then
  nitrogen.message(err ~= "" and err or ("pandoc exited with " .. tostring(code) .. "."))
  return
end

nitrogen.message("Wrote " .. pdf)
