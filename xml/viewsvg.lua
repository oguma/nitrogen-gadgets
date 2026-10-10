local svg = nitrogen.temp_file(nitrogen.text())
local new = svg:gsub("%.[^.\\/]*$", "") .. ".svg"
os.remove(new)
assert(os.rename(svg, new))

if package.config:sub(1, 1) == "\\" then
  nitrogen.run("cmd", { "/c", "start", "", new })
elseif nitrogen.run("uname", {}):match("^Darwin") then
  nitrogen.run("open", { new })
else
  nitrogen.run("xdg-open", { new })
end
