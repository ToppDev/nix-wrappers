{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    specs.navigation = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        vim-tmux-navigator
      ];
    };
  };
}
