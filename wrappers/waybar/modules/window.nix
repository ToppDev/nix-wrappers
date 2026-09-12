# Identical for both compositors, so one module declares both rather than two
# byte-identical files that can drift apart.
{...}: {
  flake.wrappers.waybar = {...}: let
    window = {
      format = "{}";
      rewrite = {
        "(.*) - Brave" = "$1";
        "(.*) - Chromium" = "$1";
      };
      separate-outputs = true;
      tooltip = false;
    };
  in {
    settings."hyprland/window" = window;
    settings."niri/window" = window;
  };
}
