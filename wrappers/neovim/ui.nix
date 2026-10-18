{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    specs.ui = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        which-key-nvim
        mini-hipatterns
      ];
    };
  };
}
