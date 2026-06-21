{self, ...}: {
  flake.wrappers.wallust = {
    pkgs,
    wlib,
    ...
  }: let
    wallustToml = (pkgs.formats.toml {}).generate "wallust.toml" {
      backend = "fastresize";
      color_space = "lch";
      palette = "dark16";
      templates = {
        hyprland = {
          template = "${./templates/hyprland.lua}";
          target = "~/.config/hypr/colors.lua";
        };
        waybar = {
          template = "${./templates/colors.css}";
          target = "~/.config/waybar/colors.css";
        };
        wlogout = {
          # Re-using the same template for wlogout
          template = "${./templates/colors.css}";
          target = "~/.config/wlogout/colors.css";
        };
      };
    };

    wrappedWallust = pkgs.writeShellApplication {
      name = "wallust";
      runtimeInputs = [pkgs.wallust];
      text = ''
        exec wallust -C ${wallustToml} "$@"
      '';
    };
  in {
    imports = [wlib.modules.default];
    package = wrappedWallust;
  };

  flake.wrappers.changewallpaper = {
    wlib,
    pkgs,
    lib,
    config,
    ...
  }: let
    wrappedWallust = self.packages.${pkgs.stdenv.hostPlatform.system}.wallust;
  in {
    imports = [wlib.modules.default];

    options = {
      logoDir = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional path to the directory containing Logo.png and Logo-white.png. If null, the logo copy block is omitted.";
      };
    };
    config = {
      package = pkgs.writeShellApplication {
        name = "changewallpaper";
        runtimeInputs = [pkgs.imagemagick pkgs.bc pkgs.gawk wrappedWallust pkgs.awww];
        text = ''
          CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}"
          CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}"

          # Change wallpaper
          awww img "$1" --transition-step 20 --transition-fps=20

          # Copy (and convert) image to cache
          magick "$1" "$CACHE_DIR/current_wallpaper.jpg"
          magick "$1" -blur 0x4 "$CACHE_DIR/current_wallpaper_blur.jpg"

          # Create new color-scheme
          brightness=$(magick "$1" -crop x60+0+0 -colorspace Gray -format "%[fx:mean]" info:)
          palette=$(echo "$brightness > 0.8" | bc -l | awk '{print ($1 == 1) ? "light16" : "dark16"}')

          wallust run --palette "$palette" --skip-sequences "$1"

          if (( $(echo "$brightness > 0.8" | bc -l) )); then
              echo "@define-color waybartext #000000;" >> "$CONFIG_DIR/waybar/colors.css"
          else
              echo "@define-color waybartext #FFFFFF;" >> "$CONFIG_DIR/waybar/colors.css"
          fi
          ${lib.optionalString (config.logoDir != null)
            # bash
            ''

              # Logo image
              logo=$(echo "$brightness > 0.8" | bc -l | awk '{print ($1 == 1) ? "" : "-white"}')
              cp "${config.logoDir}/Logo''${logo}.png" "$CACHE_DIR/logo.png"
            ''}
        '';
      };
    };
  };
}
