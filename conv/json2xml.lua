local src, pos = nitrogen.text(), 1

local function fail(msg)
  local line = select(2, src:sub(1, pos):gsub("\n", "")) + 1
  error(("line %d: %s"):format(line, msg), 0)
end

local function skip()
  pos = src:find("[^ \t\r\n]", pos) or #src + 1
end

local null = {}

local escapes = { b = "\b", f = "\f", n = "\n", r = "\r", t = "\t" }

local value

local function str()
  local out = {}
  pos = pos + 1
  while true do
    local s, e, c = src:find('(["\\])', pos)
    if not s then fail("unterminated string") end
    out[#out + 1] = src:sub(pos, s - 1)
    pos = e + 1
    if c == '"' then return table.concat(out) end
    c = src:sub(pos, pos)
    if c == "u" then
      local cp = tonumber(src:sub(pos + 1, pos + 4), 16) or fail("bad \\u escape")
      pos = pos + 5
      if cp >= 0xD800 and cp < 0xDC00 and src:sub(pos, pos + 1) == "\\u" then
        cp = 0x10000 + (cp - 0xD800) * 0x400 + (tonumber(src:sub(pos + 2, pos + 5), 16) - 0xDC00)
        pos = pos + 6
      end
      out[#out + 1] = utf8.char(cp)
    else
      out[#out + 1] = escapes[c] or c
      pos = pos + 1
    end
  end
end

local function list(close, item)
  local out = {}
  pos = pos + 1
  skip()
  if src:sub(pos, pos) == close then pos = pos + 1 return out end
  while true do
    item(out)
    skip()
    local c = src:sub(pos, pos)
    pos = pos + 1
    if c == close then return out end
    if c ~= "," then fail("expected ',' or '" .. close .. "'") end
  end
end

function value()
  skip()
  local c = src:sub(pos, pos)
  if c == "{" then
    return { obj = list("}", function(out)
      skip()
      if src:sub(pos, pos) ~= '"' then fail("expected a key") end
      local k = str()
      skip()
      if src:sub(pos, pos) ~= ":" then fail("expected ':'") end
      pos = pos + 1
      out[#out + 1] = { k, value() }
    end) }
  elseif c == "[" then
    return { arr = list("]", function(out) out[#out + 1] = value() end) }
  elseif c == '"' then
    return str()
  end
  local word = src:match("^[%w.+-]+", pos) or fail("unexpected '" .. c .. "'")
  pos = pos + #word
  return word == "null" and null or word
end

local function escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function tag(k)
  return (k:gsub("[^%w_.-]", "_"):gsub("^[^%a_]", "_"))
end

local out = {}

local function emit(name, v, ind)
  if type(v) == "table" and v.arr then
    for _, x in ipairs(v.arr) do
      if type(x) == "table" and x.arr then
        out[#out + 1] = ind .. "<" .. name .. ">"
        emit("item", x, ind .. "  ")
        out[#out + 1] = ind .. "</" .. name .. ">"
      else
        emit(name, x, ind)
      end
    end
  elseif v == null then
    out[#out + 1] = ind .. "<" .. name .. "/>"
  elseif type(v) == "table" then
    out[#out + 1] = ind .. "<" .. name .. ">"
    for _, kv in ipairs(v.obj) do emit(tag(kv[1]), kv[2], ind .. "  ") end
    out[#out + 1] = ind .. "</" .. name .. ">"
  else
    out[#out + 1] = ind .. ("<%s>%s</%s>"):format(name, escape(v), name)
  end
end

local ok, err = pcall(function()
  local docs = {}
  skip()
  while pos <= #src do
    docs[#docs + 1] = value()
    skip()
  end
  if #docs == 1 and type(docs[1]) == "table" and docs[1].obj then
    emit("json", docs[1], "")
  else
    out[1] = "<json>"
    for _, d in ipairs(docs) do emit("item", d, "  ") end
    out[#out + 1] = "</json>"
  end
end)

if not ok then
  nitrogen.message("Not JSON: " .. err)
  return
end

nitrogen.open_text(table.concat(out, "\n") .. "\n", "json.xml")
