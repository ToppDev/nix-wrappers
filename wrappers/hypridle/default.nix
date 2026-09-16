{self, ...}: {
  flake.wrappers.hypridle = {
    wlib,
    pkgs,
    lib,
    config,
    ...
  }: let
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";

    # base config to use when no host specific config is given
    baseConfText =
      # toml
      ''
        general {
            lock_cmd = pidof swaylock || swaylock  # avoid starting multiple hyprlock instances.
            before_sleep_cmd = loginctl lock-session  # lock before suspend.
            after_sleep_cmd = hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })'  # to avoid having to press a key twice to turn on the display.
        }

        listener {
            timeout = 1200
            on-timeout = hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'  # screen off when timeout has passed
            # on-resume = hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' && brightnessctl -r && sleep 3 && systemctl --user restart waybar.service # screen on when activity is detected after timeout has fired.
        }
      '';

    baseConf = pkgs.writeText "hypridle-base.conf" baseConfText;

    # Dynamically generate a config file for every host defined in extraConfigByHost
    hostConfs = lib.mapAttrs (host: text:
      pkgs.writeText "hypridle-${host}.conf" ''
        ${baseConfText}
        ${text}
      '')
    config.extraConfigByHost;

    # Generate the bash case branches for the launcher
    caseBranches = lib.concatStringsSep "\n" (lib.mapAttrsToList (host: conf: ''
        "${host}")
          ln -sf "${conf}" "$XDG_CONFIG_HOME/hypr/hypridle.conf"
          ;;
      '')
      hostConfs);

    dynamicHypridleScript = pkgs.writeShellApplication {
      name = "hypridle";

      runtimeInputs = [
        config.hypridlePackage
        pkgs.hyprland
        pkgs.systemd
        pkgs.brightnessctl
        pkgs.procps # `pidof` in lock_cmd; without it the guard always fails and a second swaylock starts
        selfpkgs.swaylock
      ];

      text = ''
        # We construct an isolated config environment in RAM to bypass the C++ bug in hypridle
        export XDG_CONFIG_HOME="''${XDG_RUNTIME_DIR:-/tmp}/hypridle-env"
        mkdir -p "$XDG_CONFIG_HOME/hypr"

        # Symlink the correct configuration based on the hostname
        case "$HOSTNAME" in
          ${caseBranches}
            *)
              ln -sf "${baseConf}" "$XDG_CONFIG_HOME/hypr/hypridle.conf"
              ;;
        esac

        # Launch the daemon natively (no -c flag required!)
        exec hypridle "$@"
      '';
    };
  in {
    imports = [wlib.modules.default];

    options = {
      hypridlePackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.hypridle;
      };
      extraConfigByHost = lib.mkOption {
        type = lib.types.attrsOf lib.types.lines;
        default = {};
        description = "Extra hypridle configuration blocks mapped by hostname";
      };
    };

    config = {
      package = dynamicHypridleScript;
      binName = "hypridle";
    };
  };
}
