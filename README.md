# Gadgets

Gadgets are small Lua scripts in Nitrogen's **Gadgets** menu. Put a `.lua`
file in the `gadgets` folder next to `nitrogenxml.exe`, and it shows up in
the menu. Folders become submenus.

```lua
nitrogen.message("Hello World!")
```

## API

```lua
nitrogen.text([n])              -- the whole text of the active tab
nitrogen.set_text(s)            -- replace it (one undo step; does not save)
nitrogen.open_text(s [, name])  -- show s in a new tab (name: untitled.xml)
nitrogen.message(s)             -- one dialog
nitrogen.file_name([n])         -- path of the active tab, or nil when unsaved

nitrogen.run(exe, args, stdin)  -- returns stdout, stderr, exit code
nitrogen.temp_file(s)           -- writes s to a temp file, returns its path
nitrogen.dir()                  -- the folder nitrogenxml.exe is in
```

`n` picks a tab: `-1` is the one to the left. Lua 5.4 with its full standard
library.

`run` can call anything on the machine, even Claude:

```lua
local out, err, code = nitrogen.run("claude",
  { "-p", "Add an XSD annotation to every element." }, nitrogen.text())
if code == 0 then nitrogen.open_text(out, "answer.xml") end
```

## Samples

These come with Nitrogen, and an update overwrites them. Keep your own
gadgets in a folder of your own.

| File | What it does |
| --- | --- |
| `csv2xml.lua` | CSV to XML |
| `md2pdf.lua` | Markdown to PDF, with pandoc and typst |
| `charcount.lua` | Counts characters, bytes and lines |
| `encoding.lua` | Guesses the encoding of the saved file |
| `lineends.lua` | Counts CRLF, LF and CR in the saved file |
| `skelsch.lua` | Schematron skeleton |
| `skelxml.lua` | XML skeleton |
| `skelxsd.lua` | XSD skeleton |
| `skelxslt1.lua` | XSLT 1.0 skeleton |
| `transform.lua` | Applies the XSLT to the XML in the tab to its left, with xsltproc |
| `validatesch.lua` | Schematron validation, with xsltproc and the ISO Schematron XSLT files in an `sch` folder next to `nitrogenxml.exe` |
| `validatexsd.lua` | XSD validation, with xmllint |
| `xmlprettify.lua` | Indents XML, with xmllint |
