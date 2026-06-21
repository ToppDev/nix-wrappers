{self, ...}: {
  flake.wrappers.wlogout = {
    wlib,
    pkgs,
    lib,
    ...
  }: let
    selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    buttons = [
      {
        label = "lock";
        action = "${pkgs.systemd}/bin/loginctl lock-session";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "hibernate";
        action = lib.getExe selfpkgs.syshibernate;
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "logout";
        action = lib.getExe selfpkgs.syslogout;
        text = "Logout";
        keybind = "e";
      }
      {
        label = "shutdown";
        action = lib.getExe selfpkgs.syspoweroff;
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "suspend";
        action = lib.getExe selfpkgs.syssuspend;
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "reboot";
        action = lib.getExe selfpkgs.sysreboot;
        text = "Reboot";
        keybind = "r";
      }
    ];

    # wlogout DOES NOT accept a JSON array [{}, {}].
    # It expects independent JSON objects separated by newlines.
    layoutJson = pkgs.writeText "wlogout-layout" (
      lib.concatMapStringsSep "\n" builtins.toJSON buttons
    );

    styleCssTemplate = pkgs.writeText "wlogout-style.css" ''
      @import url("file:///@HOME@/.config/wlogout/colors.css");

      /* -----------------------------------------------------
       * General
       * ----------------------------------------------------- */

      * {
        font-family: "Fira Sans Semibold", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
        background-image: none;
        transition: 20ms;
      }

      window {
        /* background-color: rgba(12, 12, 12, 0.1); */
        background-image: image(url("@HOME@/.cache/current_wallpaper_blur.jpg"));
      }

      button {
        color: #FFFFFF;
        font-size: 20px;

        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;

        border-style: solid;
        background-color: rgba(12, 12, 12, 0.3);
        border: 3px solid #FFFFFF;

        box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
      }

      button:focus,
      button:active,
      button:hover {
        color: @color11;
        background-color: rgba(12, 12, 12, 0.5);
        border: 3px solid @color11;
      }

      /* -----------------------------------------------------
       * Buttons
       * ----------------------------------------------------- */

      #lock {
        margin: 10px;
        border-radius: 20px;
        background-image: image(url("${./icons/lock.png}"));
      }

      #logout {
        margin: 10px;
        border-radius: 20px;
        background-image: image(url("${./icons/logout.png}"));
      }

      #suspend {
        margin: 10px;
        border-radius: 20px;
        background-image: image(url("${./icons/suspend.png}"));
      }

      #hibernate {
        margin: 10px;
        border-radius: 20px;
        background-image: image(url("${./icons/hibernate.png}"));
      }

      #shutdown {
        margin: 10px;
        border-radius: 20px;
        background-image: image(url("${./icons/shutdown.png}"));
      }

      #reboot {
        margin: 10px;
        border-radius: 20px;
        background-image: image(url("${./icons/reboot.png}"));
      }
    '';
    dynamicWlogout = pkgs.writeShellApplication {
      name = "wlogout";
      runtimeInputs = [pkgs.wlogout pkgs.gnused];
      text = ''
        # Store the generated CSS in the user's RAM-backed runtime directory (e.g., /run/user/1000/)
        CSS_PATH="''${XDG_RUNTIME_DIR:-/tmp}/wlogout-style.css"

        # Replace the @HOME@ placeholder with the actual $HOME environment variable
        sed "s|@HOME@|$HOME|g" ${styleCssTemplate} > "$CSS_PATH"

        # Launch wlogout with our generated layout, our dynamic CSS, and pass any extra flags
        exec wlogout --layout ${layoutJson} --css "$CSS_PATH" "$@"
      '';
    };
  in {
    imports = [wlib.modules.default];

    package = dynamicWlogout;

    # addFlag = [
    #   ["--layout" "${layoutJson}"]
    #   ["--css" "${styleCss}"]
    # ];
  };
}
