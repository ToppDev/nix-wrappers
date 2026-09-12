{...}: {
  flake.wrappers.swaylock = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.wrapperModules.swaylock];

    # The generated config is written as literal `key=value` lines and
    # swaylock expands nothing, so a wallpaper under $HOME cannot be a
    # setting — it went in verbatim and the lock screen simply never got a
    # background. Passed as a flag at launch instead, and only when the file
    # is actually there, since swaylock fails on a missing --image.
    package = pkgs.writeShellApplication {
      name = "swaylock";
      runtimeInputs = [pkgs.swaylock-effects];
      text = ''
        WALLPAPER="$HOME/.cache/current_wallpaper_blur.jpg"

        if [ -f "$WALLPAPER" ]; then
          exec swaylock --image "$WALLPAPER" "$@"
        fi

        exec swaylock "$@"
      '';
    };

    settings = {
      ignore-empty-password = true;
      font = "Fira Sans Semibold";

      clock = true;
      timestr = "%R";
      datestr = "%a, %e of %B";

      # screenshots = true; # Add current screenshot as wallpaper
      # image: set by the launcher above, not here — see the comment there.

      fade-in = 1; # Fade in time

      # effect-blur=2x6
      # effect-greyscale
      # effect-pixelate=2

      indicator = true; # Show/Hide indicator circle

      # smaller indicator
      indicator-radius = 200;

      # "bigger indicator" = true;
      # indicator-radius = 300;

      indicator-thickness = 20;
      indicator-caps-lock = true;

      # Define all colors
      key-hl-color = "00000066";
      separator-color = "00000000";

      inside-color = "00000033";
      inside-clear-color = "ffffff00";
      inside-caps-lock-color = "ffffff00";
      inside-ver-color = "ffffff00";
      inside-wrong-color = "ffffff00";

      ring-color = "ffffff";
      ring-clear-color = "ffffff";
      ring-caps-lock-color = "ffffff";
      ring-ver-color = "ffffff";
      ring-wrong-color = "ffffff";

      line-color = "00000000";
      line-clear-color = "ffffffFF";
      line-caps-lock-color = "ffffffFF";
      line-ver-color = "ffffffFF";
      line-wrong-color = "ffffffFF";

      text-color = "ffffff";
      text-clear-color = "ffffff";
      text-ver-color = "ffffff";
      text-wrong-color = "ffffff";

      bs-hl-color = "ffffff";
      caps-lock-key-hl-color = "ffffffFF";
      caps-lock-bs-hl-color = "ffffffFF";
      disable-caps-lock-text = true;
      text-caps-lock-color = "ffffff";
    };
  };
}
