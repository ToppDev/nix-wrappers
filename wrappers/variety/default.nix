{self, ...}: {
  flake.wrappers.variety = {
    wlib,
    pkgs,
    ...
  }: let
    selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};

    varietyPkg = pkgs.variety.overrideAttrs (old: {
      propagatedBuildInputs =
        (old.propagatedBuildInputs or [])
        ++ [
          pkgs.gnugrep
          pkgs.feh
          pkgs.swaybg
          pkgs.glib
        ];
    });
  in {
    imports = [wlib.modules.default];
    package = pkgs.writeShellApplication {
      name = "variety";
      runtimeInputs = [varietyPkg pkgs.gnused pkgs.gnugrep pkgs.coreutils selfpkgs.changewallpaper];
      text = ''
        CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/variety"
        CFG_FILE="$CONFIG_DIR/variety.conf"
        SET_WP="$CONFIG_DIR/scripts/set_wallpaper"

        # SOPS paths (ensure these match where sops-nix mounts them in your NixOS config)
        WALLHAVEN_KEY_FILE="/run/secrets/variety.wallhaven_api_key"
        SOURCES_FILE="/run/secrets/variety.sources"

        if [ -f "$CFG_FILE" ]; then
          # 1. Inject API Key
          if [ -f "$WALLHAVEN_KEY_FILE" ]; then
            wallhavenApiKey=$(cat "$WALLHAVEN_KEY_FILE")
            if [ -n "$wallhavenApiKey" ]; then
              sed -i "s/wallhaven_api_key.*/wallhaven_api_key = $wallhavenApiKey/g" "$CFG_FILE"
            fi
          fi

          # 2. Base local folder source
          if ! grep -q -e "Pictures/Wallpaper" "$CFG_FILE"; then
            src=$(grep -o -e "^src[0-9]*" "$CFG_FILE" | tail -n1)
            idx=$(( ''${src:3} + 1 ))
            sed -i "s|\(''${src}.*\)|\1\nsrc$idx = True|folder|$HOME/Pictures/Wallpaper|" "$CFG_FILE"
          fi

          # 3. External sources from SOPS
          if [ -f "$SOURCES_FILE" ]; then
            readarray -t sourcesFromFile < "$SOURCES_FILE"
            for str in "''${sourcesFromFile[@]}"; do
              if ! grep -q -e "''${str#*|}$" "$CFG_FILE"; then
                src=$(grep -o -e "^src[0-9]*" "$CFG_FILE" | tail -n1)
                idx=$(( ''${src:3} + 1 ))
                str=''${str//&/\\&}
                sed -i "s}\(''${src}.*\)}\1\nsrc$idx = $str}" "$CFG_FILE"
              fi
            done
          fi

          # 4. Filters
          if ! grep -q -e "-thumbnail 2560x1440" "$CFG_FILE"; then
            filt=$(grep -o -e "^filter[0-9]*" "$CFG_FILE" | tail -n1)
            idx=$(( ''${filt:6} + 1 ))
            filter_str="True|Padded Fit|-thumbnail 2560x1440 -background black -gravity center -extent 2560x1440"
            sed -i "s}\(''${filt}.*\)}\1\nfilter$idx = $filter_str}" "$CFG_FILE"
          fi
        fi

        # 5. Patch the set_wallpaper script to call our changewallpaper wrapper
        if [ -f "$SET_WP" ]; then
          if ! grep -q "Hyprland" "$SET_WP"; then
            # shellcheck disable=SC2016
            sed -i 's{^if \[\[ -n $SWAYSOCK || $XDG_CURRENT_DESKTOP == "Hyprland" \]\]{if [[ $XDG_CURRENT_DESKTOP == "Hyprland" || $XDG_CURRENT_DESKTOP == "niri" ]]; then\n    changewallpaper "$WP"\nel&{' "$SET_WP"
            # shellcheck disable=SC2016
            sed -i 's{^elif \[ "$DE" == "sway" \]{elif [ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]; then\n    changewallpaper "$WP"\n&{' "$SET_WP"
          fi
          # shellcheck disable=SC2016
          sed -i 's|.*change[wW]allpaper.*|    changewallpaper "$WP"|' "$SET_WP"
        fi

        exec variety "$@"
      '';
    };
  };
}
