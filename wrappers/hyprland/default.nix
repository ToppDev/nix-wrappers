{
  self,
  inputs,
  ...
}: {
  flake.wrappers.hyprland = {
    wlib,
    pkgs,
    lib,
    config,
    ...
  }: let
    selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};

    hyprsplitLuaDir = pkgs.runCommand "hyprsplit-lua" {} ''
      mkdir -p $out/hyprsplit
      cp -r ${inputs.hyprsplit}/* $out/hyprsplit/
    '';

    generatedConf = pkgs.writeText "hyprland.lua" config.luaConfig;

    dynamicHyprlandScript = pkgs.writeShellApplication {
      name = "hyprland";
      runtimeInputs = [pkgs.coreutils config.hyprlandPackage];
      text =
        # bash
        ''
          CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
          mkdir -p "$CONFIG_DIR"

          touch "$CONFIG_DIR/colors.lua"
          touch "$CONFIG_DIR/monitors.lua"

          exec hyprland -c "${generatedConf}" "$@"
        '';
    };
    customHyprland = pkgs.runCommand "hyprland" {} ''
      mkdir -p $out/bin $out/share
      ln -s ${dynamicHyprlandScript}/bin/hyprland $out/bin/hyprland
      cp -rs ${config.hyprlandPackage}/share/* $out/share/
    '';
  in {
    imports = [wlib.modules.default];

    options = {
      luaConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
      };
      hyprlandPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.hyprland;
      };
    };

    config = {
      package = customHyprland;
      passthru.providedSessions = ["hyprland"];
      filesToPatch = [
        "share/wayland-sessions/hyprland.desktop"
      ];

      luaConfig = lib.mkMerge [
        # lua
        ''
          local terminal = "${lib.getExe selfpkgs.wezterm}"
          local browser = "${lib.getExe selfpkgs.brave}"

          package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/hypr/?.lua"
          package.path = package.path .. ";${hyprsplitLuaDir}/?.lua;${hyprsplitLuaDir}/?/init.lua"

          require("colors")
          require("monitors")

          local hs = require("hyprsplit")
          hs.config({
            num_workspaces = 10,
            persistent_workspaces = false
          })
        ''
        (builtins.readFile ./settings.lua)
        (import ./_keybinds.nix {inherit self pkgs lib;})
      ];
    };
  };
}
