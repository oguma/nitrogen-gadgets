# Gadgets

Gadgets are small Lua scripts that show up in Nitrogen's **Gadgets** menu.
Drop a `.lua` file into the `gadgets` folder next to `nitrogenxml.exe` and it
is there the next time you open the menu.

Menu entries are the file names, in alphabetical order. A folder inside
`gadgets` becomes a submenu of the same name, as deep as the folders go, so
a growing pile of scripts can be sorted into folders.

Lua 5.4 is built into `nitrogenxml.exe`; the standard library is fully
available.

## API

```lua
nitrogen.text([n])              -- the whole text of the active tab
nitrogen.set_text(s)            -- replace it (one undo step; does not save)
nitrogen.open_text(s [, name])  -- show s in a new tab (name: untitled.xml)
nitrogen.message(s)             -- one dialog
nitrogen.file_name([n])         -- path of the active tab, or nil when unsaved

nitrogen.run(exe, args, stdin)  -- returns stdout, stderr, exit code
nitrogen.temp_file(s)           -- writes s to a temp file, returns its path
```

`n` picks a tab relative to the active one: `-1` is the tab to its left,
`1` the tab to its right, and leaving it out means the active tab itself.
`transform.lua` reads the tab to the left this way.

`open_text` names the tab, and the extension decides the syntax highlighting,
so pass `"rows.xml"` when you have built XML.

`file_name()` is for gadgets that care about the file itself rather than
its text: the editor buffer is already decoded and its line ends are
normalised, so `encoding.lua` and `lineends.lua` open the path and read the
raw bytes with Lua's own `io`.

`text()` raises an error when there is no such tab, `set_text()` when no
file is open. Any error a
gadget raises is shown in a dialog.

`run` waits for the command. If it takes longer than a moment, a box appears
with a Cancel button. A command that cannot be started comes back with exit
code -1 and the reason in stderr, so a gadget can say what is missing instead
of doing nothing. Temp files are deleted when Nitrogen exits.

`run` is how a gadget reaches anything else on the machine. `transform.lua`
calls xsltproc; the same four lines call a headless Claude:

```lua
local out, err, code = nitrogen.run("claude",
  { "-p", "Add an XSD annotation to every element." }, nitrogen.text())
if code == 0 then nitrogen.open_text(out, "answer.xml") end
```

## Samples

| File | What it does |
| --- | --- |
| `charcount.lua` | Counts characters, bytes and lines in the active tab. |
| `csv2xml.lua` | Turns the CSV in the active tab into XML in a new tab. |
| `encoding.lua` | Guesses the encoding of the saved file from its bytes (UTF-8, ASCII, UTF-16, Shift_JIS, EUC-JP...) and says whether Nitrogen can open it. |
| `helloworld.lua` | One dialog. The smallest gadget there is. |
| `lineends.lua` | Counts CRLF, LF and CR line ends in the saved file, and says which one Nitrogen will save with when they are mixed. |
| `md2pdf.lua` | Turns the saved Markdown file into a PDF next to it, with pandoc and typst. Unsaved edits are not included. |
| `transform.lua` | Applies the XSLT in the active tab to the XML in the tab just to its left, with xsltproc. The result opens in a new tab. |
| `validate.lua` | Validates the active tab against the XSD it names in `xsi:noNamespaceSchemaLocation`, by calling xmllint. Says so when xmllint is not on PATH. |
| `xmlprettify.lua` | Indents the XML in the active tab with `xmllint --format`, in place (one undo step). Leaves the text alone and shows the error when it is not well-formed. |
| `xmlskel.lua` | Writes an XML skeleton that links to an XSD and a Schematron schema. Fills the tab when it is empty, opens a new one when it is not. |
| `xslt1skel.lua` | Writes an XSLT 1.0 identity-transform skeleton. Fills the tab when it is empty, opens a new one when it is not. |
