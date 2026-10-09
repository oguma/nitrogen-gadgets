local xml = nitrogen.project()

if xml == nil then
  nitrogen.message("No project is open.")
  return
end

nitrogen.open_text(xml, "project.xml")
