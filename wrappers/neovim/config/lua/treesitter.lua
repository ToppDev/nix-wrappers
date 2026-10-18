-- Tree-sitter highlighting, indentation and folding for every filetype with a
-- bundled parser; filetypes without one keep regex syntax. LSP folding takes
-- over from tree-sitter folds when a server provides it (see lsp.lua).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
  callback = function(args)
    if not pcall(vim.treesitter.start, args.buf) then return end

    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

    local win = vim.fn.bufwinid(args.buf)
    if win ~= -1 and vim.wo[win][0].foldexpr ~= "v:lua.vim.lsp.foldexpr()" then
      vim.wo[win][0].foldmethod = "expr"
      vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})
