-- Native LSP. No servers are bundled: every config below is enabled, but a
-- server only starts when its executable is on PATH, i.e. when the project
-- provides it. Configs come from nvim-lspconfig, local ones from lsp/,
-- overrides from after/lsp/.
vim.lsp.enable {
  -- Nix
  "nixd",
  "devenv",
  -- Systems
  "rust_analyzer",
  "clangd",
  "cmake",
  "zls",
  -- Scripting
  "lua_ls",
  "basedpyright",
  "ruff",
  "bashls",
  "awk_ls",
  -- Web
  "ts_ls",
  "eslint",
  "html",
  "cssls",
  -- JVM
  "java_language_server",
  -- Data and config
  "jsonls",
  "jqls",
  "yamlls",
  "taplo",
  "lemminx",
  "dockerls",
  -- Documents
  "marksman",
  "texlab",
  "tinymist",
  "openscad_lsp",
}

-- These configs compute `cmd` in a function so they can prefer a server from
-- the project's node_modules/.bin, which skips Neovim's executable check and
-- would raise a spawn error wherever the server is missing. Attach them only
-- once the server is actually found, on PATH or in node_modules.
local node_servers = {
  ts_ls = "typescript-language-server",
  eslint = "vscode-eslint-language-server",
  jsonls = "vscode-json-language-server",
  html = "vscode-html-language-server",
  cssls = "vscode-css-language-server",
  yamlls = "yaml-language-server",
}
for name, exe in pairs(node_servers) do
  local base = vim.lsp.config[name]
  vim.lsp.config(name, {
    root_dir = function(bufnr, on_dir)
      local function gate(root)
        local in_project = root and vim.fn.executable(vim.fs.joinpath(root, "node_modules/.bin", exe)) == 1
        if in_project or vim.fn.executable(exe) == 1 then on_dir(root) end
      end
      if type(base.root_dir) == "function" then
        base.root_dir(bufnr, gate)
      else
        gate(base.root_dir or vim.fs.root(bufnr, base.root_markers or {}))
      end
    end,
  })
end

-- [[ UI ]]
vim.o.winborder = "rounded"
vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.foldlevelstart = 99

vim.diagnostic.config {
  severity_sort = true,
  virtual_text = { current_line = true },
  float = { source = true },
}

-- Applies to every client that advertises the capability, now and later.
-- Document colors are already on by default.
vim.lsp.inlay_hint.enable()
vim.lsp.codelens.enable()
vim.lsp.linked_editing_range.enable()
vim.lsp.on_type_formatting.enable()

-- [[ Per-client setup ]]
-- Built-in defaults already cover grn, gra, grr, gri, grt, gO, K, <C-s> and
-- [d / ]d; only the gaps are mapped here. Formatting lives in plugins/format.lua.
local group = vim.api.nvim_create_augroup("UserLsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
    map("<leader>lr", "<cmd>lsp restart<CR>", "Restart language servers")
    map("<leader>lh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }, { bufnr = bufnr })
    end, "Toggle inlay hints")

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

    if client:supports_method("textDocument/foldingRange") then
      local win = vim.fn.bufwinid(bufnr)
      if win ~= -1 then
        vim.wo[win][0].foldmethod = "expr"
        vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
      end
    end
  end,
})
