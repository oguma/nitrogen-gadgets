local path = nitrogen.file_name()
if not path then
  nitrogen.message(pcall(nitrogen.text) and "Save the file first." or "Open a file first.")
  return
end

if package.config:sub(1, 1) == "\\" then
  nitrogen.run("cmd", { "/c", "start", "", nitrogen.dir() .. "\\nitrogenxml.exe", path })
else
  nitrogen.run("sh", { "-c", '"$1" "$2" >/dev/null 2>&1 &', "sh", nitrogen.dir() .. "/nitrogenxml", path })
end
