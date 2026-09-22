# Gadgets

Gadgets are small Lua scripts that show up in Nitrogen's **Gadgets** menu.
Drop a `.lua` file into the `gadgets` folder next to `nitrogenxml.exe` and it
is there the next time you start Nitrogen. No rebuild, no install.

Menu entries are the file names, in alphabetical order. A folder inside
`gadgets` becomes a submenu of the same name, as deep as the folders go, so
a growing pile of scripts can be sorted into folders.

Lua 5.4 is built into `nitrogenxml.exe`; the standard library is fully
available.

## API

```lua
nitrogen.text()                 -- the whole text of the active tab
nitrogen.set_text(s)            -- replace it (one undo step; does not save)
nitrogen.open_text(s [, name])  -- show s in a new tab (name: untitled.xml)
nitrogen.message(s)             -- one dialog
nitrogen.file_name()            -- path of the active tab, or nil when unsaved

nitrogen.run(exe, args, stdin)  -- returns stdout, stderr, exit code
nitrogen.temp_file(s)           -- writes s to a temp file, returns its path
```

`open_text` names the tab, and the extension decides the syntax highlighting,
so pass `"rows.xml"` when you have built XML.

`file_name()` is for gadgets that care about the file itself rather than
its text: the editor buffer is already decoded and its line ends are
normalised, so `encoding.lua` and `lineends.lua` open the path and read the
raw bytes with Lua's own `io`.

`text()` and `set_text()` raise an error when no file is open. Any error a
gadget raises is shown in a dialog.

`run` waits for the command. If it takes longer than a moment, a box appears
with a Cancel button. A command that cannot be started comes back with exit
code -1 and the reason in stderr, so a gadget can say what is missing instead
of doing nothing. Temp files are deleted when Nitrogen exits.

`run` is how a gadget reaches anything else on the machine. `xml2html.lua`
calls xsltproc; the same four lines call a headless Claude:

```lua
local out, err, code = nitrogen.run("claude",
  { "-p", "Add an XSD annotation to every element." }, nitrogen.text())
if code == 0 then nitrogen.open_text(out, "answer.xml") end
```

## Samples

| File | What it does |
| --- | --- |
| `helloworld.lua` | One dialog. The smallest gadget there is. |
| `charcount.lua` | Counts characters, bytes and lines in the active tab. |
| `csv2xml.lua` | Turns the CSV in the active tab into XML in a new tab. |
| `xml2html.lua` | Runs the active tab through xsltproc and opens the outline it produces. Works on any XML. |
| `validate.lua` | Validates the active tab against the XSD it names in `xsi:noNamespaceSchemaLocation`, by calling xmllint. Says so when xmllint is not on PATH. |
| `xslt1skel.lua` | Writes an XSLT 1.0 identity-transform skeleton. Fills the tab when it is empty, opens a new one when it is not. |
