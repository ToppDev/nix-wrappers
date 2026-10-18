{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    # Server configurations only (lsp/<name>.lua on the runtimepath), not the
    # servers themselves: those come from the project being edited, via its
    # dev shell, devenv or direnv. Kept out of the lazy loader because
    # vim.lsp.enable resolves configs from the runtimepath on FileType.
    specs.lspconfig = pkgs.vimPlugins.nvim-lspconfig;
  };
}
