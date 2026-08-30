{
  self,
  pkgs,
  lib,
  ...
}: let
  selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
in
  # lua
  ''
    -- Standard Applications
    hl.bind("SUPER + BackSpace", hl.dsp.exec_cmd("${lib.getExe selfpkgs.wlogout}"))
    hl.bind("SUPER + S", hl.dsp.exec_cmd("${pkgs.fuzzel}/bin/fuzzel"))
    hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("${pkgs.fuzzel}/bin/fuzzel --list-executables-in-path"))

    hl.bind("SUPER + R", hl.dsp.exec_cmd(terminal .. " -e ${lib.getExe selfpkgs.tmux} new-session ${lib.getExe selfpkgs.yazi}"))
    hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal))
    hl.bind("SUPER + W", hl.dsp.exec_cmd(browser))

    hl.bind("SUPER + D", hl.dsp.exec_cmd("${pkgs.nwg-displays}/bin/nwg-displays"))
    hl.bind("SUPER + J", hl.dsp.exec_cmd("${pkgs.keepassxc}/bin/keepassxc"))
    hl.bind("SUPER + B", hl.dsp.exec_cmd("${pkgs.systemd}/bin/systemctl --user is-active waybar.service && ${pkgs.systemd}/bin/systemctl --user stop waybar.service || ${pkgs.systemd}/bin/systemctl --user start waybar.service"))
    hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("${pkgs.systemd}/bin/systemctl --user restart waybar.service"))
    hl.bind("SUPER + O", hl.dsp.exec_cmd("${pkgs.gnome-characters}/bin/gnome-characters"))
    hl.bind("Print", hl.dsp.exec_cmd("flameshot gui"))

    -- Window & Focus Management
    hl.bind("SUPER + Q", hl.dsp.window.close())
    hl.bind("SUPER + Slash", hl.dsp.window.float({ action = "toggle" }))
    hl.bind("SUPER + H", hl.dsp.window.fullscreen({}))
    hl.bind("SUPER + G", hl.dsp.window.swap({ next = true }))
    hl.bind("SUPER + N", hl.dsp.window.cycle_next({ next = false }))
    hl.bind("SUPER + E", hl.dsp.window.cycle_next({ next = true }))

    hl.bind("SUPER + P", hl.dsp.focus({ monitor = "-1" }))
    hl.bind("SUPER + SHIFT + P", hl.dsp.window.move({ monitor = "-1" }))
    hl.bind("SUPER + A", hl.dsp.focus({ monitor = "+1" }))
    hl.bind("SUPER + SHIFT + A", hl.dsp.window.move({ monitor = "+1" }))

    hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }))
    hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }))
    hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }))
    hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }))

    hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
    hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
    hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
    hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

    -- Special Workspaces
    hl.bind("SUPER + V", hl.dsp.workspace.toggle_special("calculator"))
    hl.bind("SUPER + SHIFT + V", hl.dsp.workspace.toggle_special("terminal"))

    -- Repeating binds (converted percentages to strict integer pixel values)
    hl.bind("SUPER + SHIFT + N", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
    hl.bind("SUPER + SHIFT + E", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })

    -- Mouse binds
    hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

    -- Repeating + Locked binds
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+"), { repeating = true, locked = true })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-"), { repeating = true, locked = true })
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true, locked = true })
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true, locked = true })
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set 15%+"), { repeating = true, locked = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set 15%-"), { repeating = true, locked = true })

    -- Locked binds
    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl next"), { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl previous"), { locked = true })
    hl.bind("XF86AudioStop", hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl stop"), { locked = true })

    -- Hyprsplit Lua dispatchers (String concatenation corrected)
    local workspace_keys = {
      ["1"] = 1, ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5,
      ["6"] = 6, ["7"] = 7, ["8"] = 8, ["9"] = 9,
      ["Y"] = 1, ["C"] = 2, ["L"] = 3, ["M"] = 4, ["K"] = 5,
      ["Z"] = 6, ["F"] = 7, ["U"] = 8, ["Comma"] = 9
    }

    for key, ws in pairs(workspace_keys) do
      hl.bind("SUPER + " .. key, hs.dsp.focus({ workspace = ws }))
      hl.bind("SUPER + SHIFT + " .. key, hs.dsp.window.move({ workspace = ws }))
    end

    hl.bind("SUPER + I", hs.dsp.focus({ workspace = "m+1" }))
    hl.bind("SUPER + Tab", hs.dsp.focus({ workspace = "m+1" }))
    hl.bind("SUPER + mouse_down", hs.dsp.focus({ workspace = "e+1" }))
    hl.bind("SUPER + mouse_up", hs.dsp.focus({ workspace = "e-1" }))
    hl.bind("SUPER + X", hs.dsp.grab_rogue_windows())
  ''
