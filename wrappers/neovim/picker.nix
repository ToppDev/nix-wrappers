{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    # fff for files and grep (Rust core, built by nixpkgs), snacks.picker for
    # every other list. Both pick up file icons from mini.icons.
    specs.picker = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        fff-nvim
        snacks-nvim
        mini-icons
      ];
    };
  };
}
