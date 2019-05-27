# lapis_layout
Converts HTML files to Lapis webframework layouts

## How to install

```
luarocks install lapis_layout
```

## How to use

### CLI samples

read content from file and outputs to `stdout` **(MoonScript layout format)**
```
lapis_layout.lua file.html -
lapis_layout.lua file.html moon
lapis_layout.lua file.html moonscript
```

read content from `stdin` and outputs to a new file **(MoonScript layout format)**
```
lapis_layout.lua - file.moon
```

read content from `stdin` and outputs to `stdout` **(Lua layout format)**
```
lapis_layout.lua - lua
```

read content from file and outputs to a new file **(Lua layout format)**
```
lapis_layout.lua file.html file.lua
```

### Using Lua

```lua
local lapis_layout = require("lapis_layout")

local moon_output, lua_output = lapis_layout({
  input = io.open("input.htm"),
  output = "output.lua",      -- optional
  tab = "  "                  -- optional
})

print("MoonScript result\n", moon_output)
print("Lua result\n", lua_output)
```

### Using MoonScript

```moonscript

```

## Known Issues

```

```
