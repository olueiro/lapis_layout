-- © 2018 <github.com/olueiro> MIT licensed
-- known issues: js inline comments; workaround: remove all them or remove script from source and add to a .js file :)

local scanner = require("web_sanitize.query.scan_html") -- luarocks install web_sanitize

local function lapis_layout(options)
  
  assert(options, "options is required")
  if type(options) == "string" then
    options = {
      input = options
    }
  end
  assert(type(options) == "table", "bad argument #1 (table expected, got " .. type(options) .. ")")

  local input = assert(options.input, "input is required")
  
  if io.type(input) == "file" then
    local handle = input
    input = handle:read("*a")
    handle:close()
  elseif type(input) == "table" then
    input = table.concat(input)
  end
  
  input = string.gsub(input, "<!%-%-.-%-%->", "") -- hard force remove HTML comments

  local nodes = {}
  
  scanner.scan_html(input, function(stack)
      local current = nodes
      for _, node in pairs(stack) do
        local num = node.num
        if current[num] then
          current = current[num]
        else
          if node.type == "text_node" then
            table.insert(current, node:inner_text())
          else
            current[num] = {
              tag = node.tag,
              attr = node.attr
            }
            current = current[num]
          end
        end
      end
  end, {
    text_nodes = true
  })

  local tab = options.tab or "  "
  
  local function raw(val)
    if string.match(val, "[\"\n']") or #val > 200 then
      local equals = 0
      string.gsub(val, "%](=*)%]", function(len)
        if #len >= equals then
          equals = #len + 1
        end
      end)
      equals = string.rep("=", equals)
      return "[" .. equals .. "[" .. val .. "]" .. equals .. "]"
    end
    val = string.gsub(val, "\\", "\\\\")
    return "\"" .. val .. "\""
  end
  
  local lua_keywords = {
    -- reserved variables
    table = true,
    select = true,
    element = true,
    raw = true,
    capture = true,
    escape = true,
    text = true,
    widget = true,
    render = true,
    render_html = true,
    self = true,

    -- Lua
    ["and"] = true,
    ["break"] = true,
    ["do"] = true,
    ["else"] = true,
    ["elseif"] = true,
    ["end"] = true,
    ["false"] = true,
    ["for"] = true,
    ["function"] = true,
    ["if"] = true,
    ["in"] = true,
    ["local"] = true,
    ["goto"] = true,
    ["nil"] = true,
    ["not"] = true,
    ["or"] = true,
    ["repeat"] = true,
    ["return"] = true,
    ["then"] = true,
    ["true"] = true,
    ["until"] = true,
    ["while"] = true,
    ["undef"] = true, -- Lua 5.4?
  }
  
  local moon_keywords = {
    -- Moonscript
    super = true,
    using = true,
    class = true,
    extends = true,
    export = true,
    import = true,
    from = true,
    new = true,
    when = true,
    switch = true,
    with = true,
    continue = true,
    unless = true,
  }
  
  for key, _ in pairs(lua_keywords) do
    moon_keywords[key] = true
  end

  local function level(node, indent)
    indent = indent or 0
    local tabs = string.rep(tab, indent)
    local moon_result, lua_result = {}, {}
    local literal
    for index = 1, #node do
      local value = node[index]
      if type(value) == "string" then
        local text = {}
        for i = index, #node do
          if type(node[i]) == "string" then
            table.insert(text, node[i])
            node[i] = true
          else
            break
          end
        end
        local raw_value = table.concat(text)
        if raw_value ~= "" then
          raw_value = raw(raw_value)
          if literal == nil then
            literal = raw_value
          end
          table.insert(moon_result, tabs .. "raw " .. raw_value)
          table.insert(lua_result, tabs .. "raw(" .. raw_value .. ")")
        end
      elseif type(value) == "table" then
        literal = false
        local tag, moon_tag, lua_tag, element = string.lower(value.tag)
        if moon_keywords[value.tag] or not string.match(tag, "^[%w%d][%w%d_]*$") then
          moon_tag = "element " .. raw(value.tag) .. ", "
          element = true
        else
          moon_tag = value.tag .. " "
        end
        if lua_keywords[value.tag] or not string.match(tag, "^[%w%d][%w%d_]*$") then
          lua_tag = "element(" ..  raw(value.tag) .. ", "
        else
          lua_tag = value.tag .. "("
        end
        local moon_attr, lua_attr = {}, {}
        if value.attr then
          for _, key in ipairs(value.attr) do
            local raw_attr = value.attr[key]
            if type(raw_attr) == "string" then
              raw_attr = raw(raw_attr)
            elseif type(raw_attr) == "boolean" then
              raw_attr = tostring(raw_attr)
            else
              raw_attr = ""
            end
            if string.match(key, "^[%w%d][%w%d_]*$") then
              table.insert(moon_attr, key .. ": " .. raw_attr)
            else
              table.insert(moon_attr, "\"" .. key .. "\": " .. raw_attr)
            end
            if not lua_keywords[key] and string.match(key, "^[%w%d][%w%d_]*$") then
              table.insert(lua_attr, key .. " = " .. raw_attr)
            else
              table.insert(lua_attr, "[\"" .. key .. "\"] = " .. raw_attr)
            end
          end
        end
        if next(moon_attr) then
          moon_attr = table.concat(moon_attr, ", ") .. ", "
          lua_attr = "{\n" .. tabs .. tab .. table.concat(lua_attr, ", \n" .. tabs .. tab) .. "\n" .. tabs .. "}, "
        else
          moon_attr, lua_attr = "", ""
        end
        local _literal_value, moon_result_level, lua_result_level = level(value, indent + 1)
        if moon_result_level == "" then
          if moon_attr == "" and not element then
            moon_result[#moon_result + 1] = string.gsub(tabs .. moon_tag, "%s$", "") .. "!"
          else
            moon_result[#moon_result + 1] = string.gsub(tabs .. moon_tag .. moon_attr, ", $", "")
          end
          lua_result[#lua_result + 1] = string.gsub(tabs .. lua_tag .. lua_attr, ", $", "") .. ")"
        else
          if _literal_value then
            table.insert(moon_result, tabs .. moon_tag .. moon_attr .. _literal_value)
            table.insert(lua_result, tabs .. lua_tag .. lua_attr .. _literal_value .. ")")
          else
            table.insert(moon_result, tabs .. moon_tag .. moon_attr .. "->\n" .. moon_result_level)
            table.insert(lua_result, tabs .. lua_tag .. lua_attr .. "function()\n" .. lua_result_level .. "\n" .. tabs .. "end)")
          end
        end
      end
    end
    return literal, table.concat(moon_result, "\n"), table.concat(lua_result, "\n")
  end
  
  local moon_output, lua_output = select(2, level(nodes))
  
  if io.type(options.output) == "file" then
    options.output:write(moon_output)
    assert(options.output:close())
  elseif type(options.output) == "string" then
    local handle = assert(io.open(options.output, "wb"))
    if string.match(string.lower(options.output), "%.lua$") then
      handle:write(lua_output)
    else
      handle:write(moon_output)
    end
    assert(handle:close())
  end

  return moon_output, lua_output

end

-- CLI
local input = arg[1]
local output = arg[2]
if input and output then
  output = string.lower(output)
  local moon_output, lua_output
  if input == "-" then
    moon_output, lua_output = lapis_layout({
      input = assert(io.read("*a"))
    })
  else
    moon_output, lua_output = lapis_layout({
      input = assert(io.open(input))
    })
  end
  if output == "moon" or output == "moonscript" or output == "-" then
    io.write(moon_output)
  elseif output == "lua" then
    io.write(lua_output)
  elseif string.match(string.lower(output), "%.lua$") then
    local file = assert(io.open(output, "w"))
    file:write(lua_output)
    assert(file:close())
  else
    local file = assert(io.open(output, "w"))
    file:write(moon_output)
    assert(file:close())
  end
end

-- Module
return lapis_layout
