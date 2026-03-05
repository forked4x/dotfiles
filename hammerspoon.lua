-- Bootstrap Lazy.spoon
local lazyDir = hs.configdir .. "/Spoons/Lazy.spoon"
if not hs.fs.attributes(lazyDir) then
  hs.execute("git clone https://github.com/forked4x/Lazy.spoon " .. lazyDir)
end
hs.loadSpoon("Lazy")

spoon.Lazy:setup({
  -- ⌨ Supercharge your Control key: Tap it for Escape. Hold it for Control.
  { "jasonrudolph/ControlEscape.spoon" },

  -- Move and resize windows
  { "forked4x/Rectangle.spoon",
    config = function()
      local mods = { "ctrl", "cmd" }
      spoon.Rectangle:bindHotkeys({
        top_left    = { mods, "q" },  top_half    = { mods, "w" },  top_right    = { mods, "e" },
        left_half   = { mods, "a" },  center_half = { mods, "s" },  right_half   = { mods, "d" },
        bottom_left = { mods, "z" },  bottom_half = { mods, "x" },  bottom_right = { mods, "c" },
        maximize    = { mods, "f" },  almost_max  = { mods, "g" },  max_height   = { mods, "9" },
        center      = { mods, "0" },  smaller     = { mods, "-" },  larger       = { mods, "=" },
        focus_left  = { mods, "h" },  focus_right = { mods, "l" },
        focus_up    = { mods, "k" },  focus_down  = { mods, "j" },  focus_under =  { mods, "i" },
      })
    end,
  },

  -- Switch apps using the right command key
  { "forked4x/Rcmd.spoon",
    config = function()
      spoon.Rcmd:bindHotkeys({
        a = "Mail",
        A = function()
          -- Copy Mail.app message link to clipboard
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
        x = "FileZilla",
        z = "Messages",
        ["`"] = "ChatGPT",
      })
    end,
  },

  -- Prevents display sleep and keeps Microsoft Teams status as "Available"
  { "forked4x/Caffeine.spoon" },

  -- Generates EmmyLua annotations for Hammerspoon
  { "Hammerspoon/Spoons/raw/master/Spoons/EmmyLua.spoon.zip" },

  keys = {
    -- Vim keybinds
    [{ "cmd", "h" }] = { "", "left",        { repeat_ = true, shift = true } },
    [{ "cmd", "j" }] = { "", "down",        { repeat_ = true, shift = true } },
    [{ "cmd", "k" }] = { "", "up",          { repeat_ = true, shift = true } },
    [{ "cmd", "l" }] = { "", "right",       { repeat_ = true, shift = true } },
    [{ "cmd", "b" }] = { "alt", "left",     { repeat_ = true, shift = true } },
    [{ "cmd", "e" }] = { "alt", "right",    { repeat_ = true, shift = true } },
    [{ "cmd", "d" }] = { "alt", "pagedown", { repeat_ = true, shift = true } },
    [{ "cmd", "u" }] = { "alt", "pageup",   { repeat_ = true, shift = true } },
    [{ "alt,cmd", "h" }] = { "cmd", "left", { shift = true } },
    [{ "alt,cmd", "j" }] = { "cmd", "down", { shift = true } },
    [{ "alt,cmd", "k" }] = { "cmd", "up",   { shift = true } },
    [{ "alt,cmd", "l" }] = { "cmd", "right",{ shift = true } },

    Things = {
      [{ "cmd", "return" }] = { "cmd",     "k", { noremap = true } },
      [{ "cmd", "delete" }] = { "alt,cmd", "k", { noremap = true } },
    },

    -- Toggle macOS dark mode
    [{ "ctrl,cmd", "n" }] = function()
      hs.osascript.applescript(
        [[tell application "System Events" to tell appearance preferences to set dark mode to ]]
        .. tostring(hs.host.interfaceStyle() ~= "Dark")
      )
    end,

    -- Reload Hammerspoon
    [{ "ctrl,cmd", "r" }] = hs.reload,
  },
})

hs.alert("Hammerspoon Loaded")
