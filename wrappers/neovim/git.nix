{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    specs.git = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        gitsigns-nvim
      ];
    };
  };
}
