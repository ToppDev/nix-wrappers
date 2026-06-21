{self, ...}: {
  flake.wrappers.wezterm = {
    wlib,
    pkgs,
    lib,
    ...
  }: let
    selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports = [wlib.wrapperModules.wezterm];

    luaInfo = {
      color_scheme = "Argonaut (Gogh)";
      colors = {
        background = "black";
        cursor_fg = "black";
      };
      window_background_opacity = 0.9;

      font = lib.generators.mkLuaInline ''
        require('wezterm').font_with_fallback {
          'FiraCode Nerd Font',
          'Broot Icons Visual Studio Code',
        }
      '';
      font_size = 12.0;

      # use_fancy_tab_bar = true;
      # enable_tab_bar = true;
      hide_tab_bar_if_only_one_tab = true;

      warn_about_missing_glyphs = false;

      # Workaround for
      # - https://github.com/NixOS/nixpkgs/issues/336069
      # - https://github.com/wez/wezterm/issues/5990
      # config.front_end="WebGpu"

      # default_prog = [ "zsh" "--login" "-c" "tmux attach -t dev || tmux new -s dev" ];
      default_prog = ["${lib.getExe selfpkgs.tmux}"];
    };
  };
}
