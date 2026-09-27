local rows = {}

local function fields(line)
  local out, i = {}, 1
  while true do
    local s, f, c = line:match("^%s*()", i)
    if line:sub(s, s) == '"' then
      local buf, j = {}, s + 1
      while true do
        local q = line:find('"', j, true)
        if not q then
          buf[#buf + 1] = line:sub(j)
          j = #line + 1
          break
        end
        buf[#buf + 1] = line:sub(j, q - 1)
        if line:sub(q + 1, q + 1) == '"' then
          buf[#buf + 1] = '"'
          j = q + 2
        else
          j = q + 1
          break
        end
      end
      f = table.concat(buf)
      c = line:find(",", j, true)
    else
      c = line:find(",", i, true)
      f = line:sub(i, (c or #line + 1) - 1):gsub("^%s+", ""):gsub("%s+$", "")
    end
    out[#out + 1] = f
    if not c then return out end
    i = c + 1
  end
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
