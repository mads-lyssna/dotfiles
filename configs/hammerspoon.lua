local hyper = { "cmd", "ctrl", "alt", "shift" }

local apps = {
  t = "Ghostty",
  x = "Visual Studio Code",
  b = "Helium",
  w = "Helium",
  c = "Calendar",
  e = "Mail",
  n = "Notion",
  s = "Slack",
  l = "Linear",
  m = "Music"
}

for key, app in pairs(apps) do
  hs.hotkey.bind(hyper, key, function()
    local running = hs.application.find(app)
    if running then
      hs.application.launchOrFocusByBundleID(running:bundleID())
    else
      hs.application.launchOrFocus(app)
    end
  end)
end
