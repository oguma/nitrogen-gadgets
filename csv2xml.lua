local rows = {}

local function fields(line)
  local out = {}
  for f in (line .. ","):gmatch("([^,]*),") do
    out[#out + 1] = (f:gsub("^%s+", ""):gsub("%s+$", ""))
  end
  return out
end

local function escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

for line in nitrogen.text():gmatch("[^\r\n]+") do
  rows[#rows + 1] = fields(line)
end

if #rows == 0 then
  nitrogen.message("Nothing to convert.")
  return
end

local head = table.remove(rows, 1)
local out = { "<rows>" }

for _, row in ipairs(rows) do
  out[#out + 1] = "  <row>"
  for i, value in ipairs(row) do
    local name = head[i] or ("col" .. i)
    name = name:gsub("[^%w_.-]", "_"):gsub("^[^%a_]", "_")
    out[#out + 1] = ("    <%s>%s</%s>"):format(name, escape(value), name)
  end
  out[#out + 1] = "  </row>"
end

out[#out + 1] = "</rows>"
nitrogen.open_text(table.concat(out, "\n") .. "\n", "rows.xml")
