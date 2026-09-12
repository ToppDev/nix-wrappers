{self, ...}: {
  flake.wrappers.waybar = {
    wlib,
    pkgs,
    lib,
    ...
  }: let
    # Waybar 0.15.0 has no clickable workspaces for lua hyprland
    # https://github.com/Alexays/Waybar/pull/5013
    waybar =
      (pkgs.waybar.override {
        cavaSupport = false;
      }).overrideAttrs (old: {
        version = "0.15.0-git-09e69e0";
        src = pkgs.fetchFromGitHub {
          owner = "Alexays";
          repo = "Waybar";
          rev = "09e69e0f48214a1128d62417612bc47e8dc9e36a"; # full sha1: the 39-char form only resolved because GitHub accepts abbreviated archive refs
          hash = "sha256-grYWj1RHrkhM0NCIymTsZyObuQsCVf1kuzLaThwMxvc=";
        };

        mesonFlags =
          (old.mesonFlags or [])
          ++ [
            "-Dwwan=disabled"
          ];
        doInstallCheck = false; # searches for version 0.15.0 exactly
      });

    # 1. Runtime launcher: the store copies of the CSS and the config both
    #    contain placeholders that can only be resolved once a user session
    #    exists, so both are rewritten into $XDG_RUNTIME_DIR at launch and
    #    passed explicitly. The corresponding flags from the wrapper module are
    #    force-disabled below.
    dynamicWaybar = pkgs.writeShellApplication {
      name = "waybar";
      runtimeInputs = [waybar pkgs.gnused pkgs.coreutils pkgs.findutils];
      text = ''
        RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/tmp}"
        CSS_PATH="$RUNTIME_DIR/waybar-style.css"
        CONFIG_PATH="$RUNTIME_DIR/waybar-config.json"
        HWMON_SYMLINK="$RUNTIME_DIR/waybar_cpu_hwmon"

        # Copy the CSS from the Nix store to a runtime path, replacing @HOME@
        sed "s|@HOME@|$HOME|g" ${./style.css} > "$CSS_PATH"

        # Dynamically find the CPU temperature sensor and create a stable symlink
        CPU_HWMON_DIR=$(grep -l -e "k10temp" -e "coretemp" /sys/class/hwmon/hwmon*/name 2>/dev/null | head -n1 | xargs -r dirname)

        if [ -n "$CPU_HWMON_DIR" ]; then
          ln -sfn "$CPU_HWMON_DIR" "$HWMON_SYMLINK"
        fi

        # The temperature module's hwmon-path points at that symlink. waybar
        # expands no variables of its own, so the path is substituted here —
        # without this the module reads a path nothing ever creates and the
        # temperature never appears.
        sed "s|@HWMON@|$HWMON_SYMLINK|g" "${configFile}" > "$CONFIG_PATH"

        exec waybar --config "$CONFIG_PATH" --style "$CSS_PATH" "$@"
      '';
    };

    # Bound here rather than read back from config.configFile.path: that
    # path is derived from binName, which comes from the package, and the
    # launcher below *is* the package — reading it would close a cycle.
    waybarSettings = {
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
      # Same shape for both compositors, so one file serves both rather than a
      # byte-identical copy that can drift.
      "niri/window" = import ./modules/_hyprland-window.nix {inherit pkgs;};
      "niri/workspaces" = import ./modules/_niri-workspaces.nix {inherit pkgs;};
      "power-profiles-daemon" = import ./modules/_power-profiles-daemon.nix {inherit pkgs;};
      "pulseaudio" = import ./modules/_pulseaudio.nix {inherit pkgs;};
      "wlr/taskbar" = import ./modules/_taskbar.nix {inherit pkgs;};
      "tray" = import ./modules/_tray.nix {inherit pkgs;};
      "image" = import ./modules/_image.nix {inherit pkgs;};
      "temperature" = import ./modules/_temperature.nix {};
    };
    configFile = pkgs.writeText "waybar-config.json" (builtins.toJSON waybarSettings);
  in {
    imports = [wlib.wrapperModules.waybar];

    package = dynamicWaybar;

    # The wrapper module automatically injects `--config` and `--style`
    # pointing into the store. Both are force-disabled here: the launcher above
    # passes its own rewritten copies, and a store path cannot carry either the
    # user's $HOME or the session's runtime directory.
    flags."--style" = lib.mkForce null;
    flags."--config" = lib.mkForce null;

    # "style.css".path = ./style.css;

    settings = waybarSettings;
  };
}
