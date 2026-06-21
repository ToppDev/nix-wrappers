-- conf/settings.lua
hl.config({
  general = {
    border_size = 2,
    col = {
      active_border = { 
        colors = { color11, color13 }, 
        angle = 45 
      },
      inactive_border = "rgba(595959aa)",
    }
  },
  decoration = {
    rounding = 10,
    rounding_power = 2,
    inactive_opacity = 1.0,
    dim_inactive = false,
    blur = {
      enabled = true,
      size = 3
    },
    shadow = {
      enabled = true
    }
  },
  animations = {
    enabled = true,
  },
  input = {
    kb_layout = "us",
    kb_variant = "altgr-intl",
    repeat_delay = 200,
    touchpad = {
      natural_scroll = true
    }
  },
  device = {
    {
      name = "at-translated-set-2-keyboard",
      kb_layout = "de",
      kb_variant = "nodeadkeys"
    }
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true
  },
  cursor = {
    inactive_timeout = 2
  },
  ecosystem = {
    no_update_news = false,
    no_donation_nag = true
  }
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default springs
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Fallback Monitor Rule (Applied if specific host monitors are missing)
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Window Rules
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false }, no_initial_focus = true })
hl.window_rule({ match = { class = "^org\\.gnome\\.Characters$" }, float = true })
hl.window_rule({ match = { class = "^steam$", title = "^Friends List$" }, float = true })
hl.window_rule({ match = { class = "^Brave-browser$", title = ".*YouTube - Brave$" }, opacity = "1.0 override" })
hl.window_rule({ match = { class = "thunderbird", initial_title = "^Calendar Reminders$" }, float = true })
hl.window_rule({ match = { class = "thunderbird", initial_title = ".*Reminder$" }, float = true })
hl.window_rule({ match = { class = "thunderbird", initial_title = "^Edit Item$" }, float = true })
hl.window_rule({ match = { class = "thunderbird", title = "^Write:.*" }, float = true })
hl.window_rule({ match = { class = "thunderbird", initial_title = "^$" }, float = true })
hl.window_rule({ match = { class = "nwg-displays", title = "^nwg-displays$" }, float = true })
hl.window_rule({ match = { initial_title = "^flameshot-pin$" }, float = true, size = "0% 0%" })
hl.window_rule({ match = { title = "^Save File$" }, float = true, center = true, size = "50% 50%" })
hl.window_rule({ match = { title = ".*wants to save$" }, float = true, center = true, size = "50% 50%" })
hl.window_rule({ match = { title = "^flameshot$" }, move = "0 0", pin = true, fullscreen_state = "2 2", float = true })

-- Workspace Rules
hl.workspace_rule({ workspace = "special:calculator", on_created_empty = "[float; size 50% 40%] wezterm --config font_size=16 --config \"window_close_confirmation='NeverPrompt'\" start --cwd /tmp -- octave --no-gui --silent --persist --eval \"fprintf('GNU Octave - version '); disp(version); disp(' ');\"" })
hl.workspace_rule({ workspace = "special:terminal", on_created_empty = "[float; size 70% 60%] wezterm --config font_size=14" })
