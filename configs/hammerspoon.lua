local hyper = { "cmd", "ctrl", "alt", "shift" }

local apps = {
  t = "io.appmakes.otty",
  x = "dev.zed.Zed",
  b = "net.imput.helium",
  w = "net.imput.helium",
  c = "com.apple.iCal",
  e = "com.apple.mail",
  n = "notion.id",
  s = "com.tinyspeck.slackmacgap",
  l = "com.linear",
  m = "com.apple.Music"
}

for key, bundleID in pairs(apps) do
  hs.hotkey.bind(hyper, key, function()
    hs.application.launchOrFocusByBundleID(bundleID)
  end)
end
