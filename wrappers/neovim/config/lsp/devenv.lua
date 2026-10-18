-- nixd pre-configured with devenv's nixpkgs and option set. Attach only in an
-- actual devenv project: elsewhere `devenv lsp` would bootstrap a .devenv
-- directory in an unrelated repo.
return {
  cmd = { "devenv", "lsp" },
  filetypes = { "nix" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, "devenv.nix")
    if root then on_dir(root) end
  end,
}
