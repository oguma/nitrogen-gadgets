local svg = nitrogen.temp_file(nitrogen.text(), ".svg")

if package.config:sub(1, 1) == "\\" then
  nitrogen.run("cmd", { "/c", "start", "", svg })
elseif nitrogen.run("uname", {}):match("^Darwin") then
  nitrogen.run("open", { svg })
else
  nitrogen.run("xdg-open", { svg })
end
