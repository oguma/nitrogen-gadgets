local exe = "castle-model-viewer"
local windows = package.config:sub(1, 1) == "\\"

local path = nitrogen.file_name() or nitrogen.temp_file(nitrogen.text(), ".x3d")

local _, _, found = nitrogen.run(windows and "where" or "which", { exe })
if found ~= 0 then
  nitrogen.message(
    exe .. " was not found.\n\n" ..
    "Install Castle Model Viewer, put it on PATH, and run this gadget again.")
  return
end

if windows then
  nitrogen.run("cmd", { "/c", "start", "", exe, "--hide-extras", path })
else
  nitrogen.run("sh", { "-c", exe .. ' --hide-extras "$1" >/dev/null 2>&1 &', "sh", path })
end
