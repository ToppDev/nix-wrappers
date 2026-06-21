{self, ...}: {
  flake.wrappers.waybar = {
    wlib,
    pkgs,
    lib,
    ...
  }: let
    # 1. Create a runtime launcher to dynamically substitute $HOME in the CSS
    dynamicWaybar = pkgs.writeShellApplication {
      name = "waybar";
      runtimeInputs = [pkgs.waybar pkgs.gnused pkgs.coreutils pkgs.findutils];
      text = ''
        CSS_PATH="''${XDG_RUNTIME_DIR:-/tmp}/waybar-style.css"
        HWMON_SYMLINK="''${XDG_RUNTIME_DIR:-/tmp}/waybar_cpu_hwmon"

        # Copy the CSS from the Nix store to a runtime path, replacing @HOME@
        sed "s|@HOME@|$HOME|g" ${./style.css} > "$CSS_PATH"

        # Dynamically find the CPU temperature sensor and create a stable symlink
        CPU_HWMON_DIR=$(grep -l -e "k10temp" -e "coretemp" /sys/class/hwmon/hwmon*/name 2>/dev/null | head -n1 | xargs -r dirname)

        if [ -n "$CPU_HWMON_DIR" ]; then
          ln -sfn "$CPU_HWMON_DIR" "$HWMON_SYMLINK"
        fi

        exec waybar --style "$CSS_PATH" "$@"
      '';
    };
  in {
    imports = [wlib.wrapperModules.waybar];

    package = dynamicWaybar;

    # The wrapper module automatically injects `--style /nix/store/...`.
    # We force disable it here since our dynamic launcher handles the style flag manually.
    flags."--style" = lib.mkForce null;

    # "style.css".path = ./style.css;

    settings = {
      layer = "top";
      height = 16;
      margin = "14 0 0 0";
      spacing = 0;
      reload_style_on_change = true;

      modules-left = [
        "image"
        "group/quicklinks"
        "hyprland/window"
      ];
      modules-center = [
        "hyprland/workspaces"
      ];
      modules-right = [
        "group/hardware"
        "battery"
        "pulseaudio"
        "bluetooth"
        "network"
        "clock"
        "custom/exit"
        "tray"
      ];

      "group/quicklinks" = {
        orientation = "horizontal";
        modules = ["custom/brave" "custom/windowsvm"];
      };

      "group/hardware" = {
        orientation = "horizontal";
        modules = ["temperature" "cpu" "memory" "disk"];
      };

      "backlight" = import ./modules/_backlight.nix {inherit pkgs;};
      "battery" = import ./modules/_battery.nix {inherit pkgs;};
      "bluetooth" = import ./modules/_bluetooth.nix {inherit pkgs;};
      "clock" = import ./modules/_clock.nix {inherit pkgs;};
      "cpu" = import ./modules/_cpu.nix {inherit self pkgs lib;};
      "custom/appmenu" = import ./modules/_custom-appmenu.nix {inherit pkgs;};
      "custom/brave" = import ./modules/_custom-brave.nix {inherit self pkgs lib;};
      "custom/windowsvm" = import ./modules/_custom-windowsvm.nix {inherit pkgs;};
      "custom/exit" = import ./modules/_custom-exit.nix {inherit self pkgs lib;};
      "disk" = import ./modules/_disk.nix {inherit pkgs;};
      "hyprland/window" = import ./modules/_hyprland-window.nix {inherit pkgs;};
      "hyprland/workspaces" = import ./modules/_hyprland-workspaces.nix {inherit pkgs;};
      "keyboard-state" = import ./modules/_keyboard-state.nix {inherit pkgs;};
      "memory" = import ./modules/_memory.nix {inherit self pkgs lib;};
      "network" = import ./modules/_network.nix {inherit pkgs;};
      "niri/window" = import ./modules/_niri-window.nix {inherit pkgs;};
      "niri/workspaces" = import ./modules/_niri-workspaces.nix {inherit pkgs;};
      "power-profiles-daemon" = import ./modules/_power-profiles-daemon.nix {inherit pkgs;};
      "pulseaudio" = import ./modules/_pulseaudio.nix {inherit pkgs;};
      "wlr/taskbar" = import ./modules/_taskbar.nix {inherit pkgs;};
      "tray" = import ./modules/_tray.nix {inherit pkgs;};
      "image" = import ./modules/_image.nix {inherit pkgs;};
      "temperature" = import ./modules/_temperature.nix {};
    };
  };
}
