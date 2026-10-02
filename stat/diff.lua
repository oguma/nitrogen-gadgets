local function lines(s)
  local t = {}
  if s == "" then return t end
  s = s:gsub("\r\n", "\n")
  if s:sub(-1) ~= "\n" then s = s .. "\n" end
  for l in s:gmatch("(.-)\n") do t[#t + 1] = l end
  return t
end

local a = lines(nitrogen.text(-1))
local b = lines(nitrogen.text())

local p = 0
while p < #a and p < #b and a[p + 1] == b[p + 1] do p = p + 1 end
local q = 0
while q < #a - p and q < #b - p and a[#a - q] == b[#b - q] do q = q + 1 end

local m, n = #a - p - q, #b - p - q
local w = n + 1
local L = {}
for i = m, 0, -1 do
  for j = n, 0, -1 do
    local v
    if i == m or j == n then
      v = 0
    elseif a[p + i + 1] == b[p + j + 1] then
      v = L[(i + 1) * w + j + 1] + 1
    else
      local x, y = L[(i + 1) * w + j], L[i * w + j + 1]
      v = x > y and x or y
    end
    L[i * w + j] = v
  end
end

local ops = {}
for k = 1, p do ops[#ops + 1] = { " ", a[k] } end
local i, j = 0, 0
while i < m or j < n do
  if i < m and j < n and a[p + i + 1] == b[p + j + 1] then
    ops[#ops + 1] = { " ", a[p + i + 1] }
    i, j = i + 1, j + 1
  elseif j < n and (i == m or L[i * w + j + 1] >= L[(i + 1) * w + j]) then
    ops[#ops + 1] = { "+", b[p + j + 1] }
    j = j + 1
  else
    ops[#ops + 1] = { "-", a[p + i + 1] }
    i = i + 1
  end
end
for k = #a - q + 1, #a do ops[#ops + 1] = { " ", a[k] } end

local olds, news = {}, {}
local o, nn = 1, 1
for k, op in ipairs(ops) do
  olds[k], news[k] = o, nn
  if op[1] ~= "+" then o = o + 1 end
  if op[1] ~= "-" then nn = nn + 1 end
end

local out = {
  "--- " .. (nitrogen.file_name(-1) or "untitled"),
  "+++ " .. (nitrogen.file_name() or "untitled"),
}
local k = 1
while k <= #ops do
  if ops[k][1] ~= " " then
    local s = math.max(1, k - 3)
    local e = k
    local c = k + 1
    while c <= #ops and c - e <= 6 do
      if ops[c][1] ~= " " then e = c end
      c = c + 1
    end
    e = math.min(#ops, e + 3)
    local oc, nc = 0, 0
    for x = s, e do
      if ops[x][1] ~= "+" then oc = oc + 1 end
      if ops[x][1] ~= "-" then nc = nc + 1 end
    end
    local os, ns = olds[s], news[s]
    if oc == 0 then os = os - 1 end
    if nc == 0 then ns = ns - 1 end
    out[#out + 1] = string.format("@@ -%d,%d +%d,%d @@", os, oc, ns, nc)
    for x = s, e do out[#out + 1] = ops[x][1] .. ops[x][2] end
    k = e + 1
  else
    k = k + 1
  end
end

if #out == 2 then
  nitrogen.message("No differences.")
else
  nitrogen.open_text(table.concat(out, "\n") .. "\n", "untitled.diff")
end
