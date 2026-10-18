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

-- Set `vim.g.autoformat = false` (or `vim.b.autoformat`) to stop formatting
-- on save.
vim.g.autoformat = true

-- [[ Per-client setup ]]
-- Built-in defaults already cover grn, gra, grr, gri, grt, gO, K, <C-s> and
-- [d / ]d; only the gaps are mapped here.
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
    map("<leader>lf", function() vim.lsp.buf.format { bufnr = bufnr } end, "Format buffer")
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

    -- One hook per buffer, however many clients attach (or reattach after a
    -- restart); format() itself asks every client that supports it.
    if client:supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds { group = group, buffer = bufnr, event = "BufWritePre" }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        buffer = bufnr,
        callback = function()
          if vim.b[bufnr].autoformat == false or not vim.g.autoformat then return end
          vim.lsp.buf.format { bufnr = bufnr, timeout_ms = 2000 }
        end,
      })
    end
  end,
})
