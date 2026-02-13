-- Download Spoons, if required
local f = io.open("Spoons/EmmyLua.spoon/annotations/hs.lua")
if f ~= nil then io.close(f) else
  hs.alert("Downloading Spoons")
  os.execute([[
    mkdir -p Spoons && cd Spoons &&
    git clone https://github.com/jasonrudolph/ControlEscape.spoon.git
    git clone https://github.com/forkde4x/Rectangle.spoon.git
    git clone https://github.com/forkde4x/Rcmd.spoon.git
    git clone https://github.com/forkde4x/KeyMapper.spoon.git
    curl -LO https://github.com/Hammerspoon/Spoons/raw/master/Spoons/EmmyLua.spoon.zip &&
    unzip ~/.config/hammerspoon/Spoons/EmmyLua.spoon.zip &&
    rm ~/.config/hammerspoon/Spoons/EmmyLua.spoon.zip && cd -
  ]])
  -- Hammerspoon annotations for lua language server
  hs.loadSpoon("EmmyLua")
end

-- Caps Lock acts as Esc when tapped, Ctrl when held
hs.loadSpoon("ControlEscape")
spoon.ControlEscape:start()

-- Move and resize windows
hs.window.animationDuration = 0.1
local mods = { "ctrl", "cmd" }
hs.loadSpoon("Rectangle")
spoon.Rectangle:bindHotkeys({
  top_left    = { mods, "q" },  top_half    = { mods, "w" },  top_right    = { mods, "e" },
  left_half   = { mods, "a" },  center_half = { mods, "s" },  right_half   = { mods, "d" },
  bottom_left = { mods, "z" },  bottom_half = { mods, "x" },  bottom_right = { mods, "c" },
  maximize    = { mods, "f" },  almost_max  = { mods, "g" },  max_height   = { mods, "9" },
  center      = { mods, "0" },  smaller     = { mods, "-" },  larger       = { mods, "=" },
  focus_left  = { mods, "h" },  focus_right = { mods, "l" },
  focus_up    = { mods, "k" },  focus_down  = { mods, "j" },  focus_under =  { mods, "i" },
})
spoon.Rectangle:config({ margins = 7 })

-- Switch apps using the right command key
hs.loadSpoon("Rcmd")
hs.loadSpoon("Caffeine")
spoon.Rcmd:bindHotkeys({
  a = "Mail",
  A = function() -- Copy Mail.app message link to clipboard
    local script = [[
      tell application "Mail"
        set emails to selection
        set email to item 1 of emails
        set msgid to message id of email
        set subj to subject of email
        set the clipboard to "✉️ " & subj & "\nmessage://%3c" & msgid & "%3e"
      end tell
    ]]
    hs.osascript.applescript(script)
    hs.alert("Copied email link to clipboard")
  end,
  c = "Calendar",
  C = function() spoon.Caffeine:toggle() end,
  d = "Things3",
  e = "Microsoft Excel",
  f = "Finder",
  g = function() hs.urlevent.openURL("https://www.google.ca") end,
  G = "Google Chrome",
  h = "Hammerspoon",
  k = function() hs.application.frontmostApplication():hide() end,
  m = "Music",
  n = "Notion",
  o = function() hs.urlevent.openURL("https://openrouter.ai/chat") end,
  O = function()
    local app = hs.application.open("OTP Manager")
    hs.timer.waitUntil(
      function()
        return hs.application.frontmostApplication():name() == "OTP Manager"
      end,
      function()
        hs.application.frontmostApplication():selectMenuItem("Open Main Window")
        hs.timer.waitUntil(
          function() return app:mainWindow() end,
          function()
            local screen = hs.screen.mainScreen()
            local menubar = screen:fullFrame().h - screen:frame().h
            local gap = 7
            app:mainWindow():setTopLeft({ gap, menubar + gap })
          end,
          0.1)
      end,
      0.1)
  end,
  p = "Photos",
  P = "OpenVPN Connect",
  q = "Safari",
  r = "Microsoft Remote Desktop",
  s = "TablePlus",
  t = "Microsoft Teams",
  w = function()
    local front = hs.application.frontmostApplication()
    if front:name() == "kitty" then front:hide(); return end
    local app = hs.application.find("kitty", true)
    if app then app:activate()
    else
      -- Need to use bundleID otherwise it can find Safari with kitty tab open
      app = hs.application.open("net.kovidgoyal.kitty", nil, true)
      hs.timer.waitUntil(
        function()
          return hs.application.frontmostApplication():name() == "kitty"
        end,
        function()
          hs.timer.doAfter(0.2, function()
            spoon.Rectangle:right_half()
          end)
      end,
      0.1)
    end
  end,
  W = "aider-desk",
  x = "FileZilla",
  z = "Messages",
  ["`"] = "ChatGPT",
}):start()

-- Vim Keybinds
local keymaps = {
  default = {
    [{ "cmd", "h" }]     = { "",    "left",     true },
    [{ "cmd", "j" }]     = { "",    "down" ,    true },
    [{ "cmd", "k" }]     = { "",    "up",       true },
    [{ "cmd", "l" }]     = { "",    "right",    true },
    [{ "cmd", "b" }]     = { "alt", "left",     true },
    [{ "cmd", "e" }]     = { "alt", "right",    true },
    [{ "cmd", "d" }]     = { "alt", "pagedown", true },
    [{ "cmd", "u" }]     = { "alt", "pageup",   true },
    [{ "cmd,alt", "h" }] = { "cmd", "left" },
    [{ "cmd,alt", "j" }] = { "cmd", "down" },
    [{ "cmd,alt", "k" }] = { "cmd", "up" },
    [{ "cmd,alt", "l" }] = { "cmd", "right" },
  },
  Things = {
    [{ "cmd", "return" }] = { "cmd",     "k" },
    [{ "cmd", "delete" }] = { "cmd,alt", "k" },
  },
}
-- Add shift version of default keymaps for selection
local shiftmaps = {}
for lhs, rhs in pairs(keymaps.default) do
  shiftmaps[{ "shift," .. lhs[1], lhs[2] }] = { "shift," .. rhs[1], rhs[2], rhs[3] }
end
for lhs, rhs in pairs(shiftmaps) do keymaps.default[lhs] = rhs end
hs.loadSpoon("KeyMapper")
spoon.KeyMapper:bindHotkeys(keymaps):start()

hs.loadSpoon("AltClipboard")
spoon.AltClipboard:start()

-- Toggle macOS dark mode
hs.hotkey.bind({ "ctrl", "cmd" }, "n", function()
  hs.osascript.applescript(
    [[tell application "System Events" to tell appearance preferences to set dark mode to ]]
    .. tostring(hs.host.interfaceStyle() ~= "Dark")
  )
end)

-- Reload Hammerspoon
hs.hotkey.bind({ "ctrl", "cmd" }, "r", hs.reload)

hs.alert("Hammerspoon Loaded")
