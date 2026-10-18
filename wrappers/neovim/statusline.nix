{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    specs.statusline = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        lualine-nvim
      ];
    };
  };
}
