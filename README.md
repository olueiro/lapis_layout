# lapis_layout
Converts HTML files to Lapis webframework layouts

## WTF is this?

[Lapis webframework](https://leafo.net/lapis/) has a cool [HTML generation](https://leafo.net/lapis/reference/html_generation.html) tool. This module helps you to convert HTML files (from templates, etc) to Lapis layout format (supports MoonScript and Lua).

### Sample:

This HTML:
```html
<!DOCTYPE HTML><html lang="en"><head><title></title></head><body>Hello<span class="a b c">World</span>!</body></html>
```
converts to this **MoonScript** string:
```moonscript
raw "<!DOCTYPE HTML>"
html lang: "en", ->
  head ->
    title!
  body ->
    raw "Hello"
    span class: "a b c", "World"
    raw "!"
```
or this **Lua** string:
```lua
raw("<!DOCTYPE HTML>")
html({
  lang = "en"
}, function()
  head(function()
    title()
  end)
  body(function()
    raw("Hello")
    span({
      class = "a b c"
    }, "World")
    raw("!")
  end)
end)
```

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

### Lua sample

```lua
local lapis_layout = require("lapis_layout")

local moon_output, lua_output = lapis_layout({
  input     = io.open("input.htm"),
  -- input  = "<html></html>",
  
  output    = "output.lua",             -- (optional) save output to file (Lua layout format)
  -- output = "output.moon",            -- (optional) save output to file (MoonScript layout format)
  -- output = io.open("output", "w"),   -- (optional) save output to file (MoonScript layout format)
  
  tab       = "  "                      -- (optional) use this value as indention
})

print("MoonScript result:\n", moon_output)
print("Lua result:\n", lua_output)
```

### MoonScript sample

```moonscript
lapis_layout = require "lapis_layout"

moon_output, lua_output = lapis_layout {
  input: io.open "input.htm"
  -- input: "<html></html>"
  
  output: "output.lua"                -- (optional) save output to file (Lua layout format)
  -- output: "output.moon"            -- (optional) save output to file (MoonScript layout format)
  -- output: io.open "output", "w"    -- (optional) save output to file (MoonScript layout format)
  
  tab: "  "                           -- (optional) use this value as indention
}

print "MoonScript result:\n", moon_output
print "Lua result:\n", lua_output
```

## TODO (help wanted)

 - **Fix bugs**
 - **Test files**
 - **Fix typos**
 - **New samples**
 - **New features:**
     - raw or text mode
     - [widgets](https://leafo.net/lapis/reference/html_generation.html#html-widgets) management?
     - online convert tool?

## Known Issues

 - **Inline JS comments:**
     - workaround: remove all them or remove script from source and add to a `.js` file :)

## License (MIT)

```
MIT License

Copyright (c) 2019 olueiro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
