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
  m = "Music"
}

for key, app in pairs(apps) do
  hs.hotkey.bind(hyper, key, function()
    hs.application.launchOrFocus(app)
  end)
end
