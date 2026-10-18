{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    # Formatters themselves are not bundled: like language servers, they come
    # from the project's environment and are skipped where missing.
    specs.format = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        conform-nvim
      ];
    };
  };
}
