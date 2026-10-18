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
-- Completion menu while typing: language servers first (through
-- 'omnifunc'), then words from the current and other open buffers. CTRL-Y
-- accepts, CTRL-N / CTRL-P move, CTRL-E dismisses.
vim.o.autocomplete = true
vim.o.complete = "o,.^5,w^5,b^5"
vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.completeitemalign = "kind,abbr,menu"

-- Only in file buffers: pickers, prompts and other plugin windows type into
-- scratch buffers where a word menu just gets in the way
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = vim.api.nvim_create_augroup("UserAutocomplete", { clear = true }),
  callback = function(args)
    vim.bo[args.buf].autocomplete = vim.bo[args.buf].buftype == ""
  end,
})
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
-- Built-in defaults stay for grn, gra, K, <C-s> and [d / ]d; the location
-- lists are moved into the picker. Formatting lives in plugins/format.lua.
local group = vim.api.nvim_create_augroup("UserLsp", { clear = true })

-- Document highlights live as extmarks in this namespace
local references_ns = vim.api.nvim_create_namespace "nvim.lsp.references"

local function reference_at_cursor()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local pos = { row - 1, col }
  return vim.api.nvim_buf_get_extmarks(0, references_ns, pos, pos, { overlap = true })
end

local function jump_reference(dir)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local marks = vim.api.nvim_buf_get_extmarks(0, references_ns, 0, -1, {})
  for i = dir > 0 and 1 or #marks, dir > 0 and #marks or 1, dir do
    local r, c = marks[i][2] + 1, marks[i][3]
    if (r - row) * dir > 0 or (r == row and (c - col) * dir > 0) then
      vim.api.nvim_win_set_cursor(0, { r, c })
      return
    end
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
    end
    -- Navigation lists go through snacks.picker (plugins/picker.lua)
    local function pick(source)
      return function() require("snacks").picker[source]() end
    end
    map("gd", pick "lsp_definitions", "Go to definition")
    map("gD", pick "lsp_declarations", "Go to declaration")
    map("grr", pick "lsp_references", "References")
    map("gri", pick "lsp_implementations", "Implementations")
    map("grt", pick "lsp_type_definitions", "Type definitions")
    map("gO", pick "lsp_symbols", "Document symbols")
    map("<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
    map("<leader>lr", "<cmd>lsp restart<CR>", "Restart language servers")
    map("<leader>lh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }, { bufnr = bufnr })
    end, "Toggle inlay hints")

    if client:supports_method("textDocument/completion") then
      -- Trigger characters such as "." still ask the server directly; the
      -- integration also expands snippets and applies extra edits on accept
      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true,
        -- The item kind as an icon, shown in front of the text
        convert = function(item)
          local kind = vim.lsp.protocol.CompletionItemKind[item.kind]
          if not kind then return {} end
          local icon, hl = require("mini.icons").get("lsp", kind:lower())
          return { kind = icon, kind_hlgroup = hl }
        end,
      })
      vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get, { buffer = bufnr, desc = "Complete" })
      -- The server already offers this buffer's identifiers; scanning it too
      -- would list each of them twice
      vim.bo[bufnr].complete = "o,w^5,b^5"
    end

    if client:supports_method("textDocument/foldingRange") then
      local win = vim.fn.bufwinid(bufnr)
      if win ~= -1 then
        vim.wo[win][0].foldmethod = "expr"
        vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
      end
    end

    -- Highlight other references to the symbol under the cursor once it rests.
    -- They stay while the cursor moves among them, so ]r / [r can walk them.
    if client:supports_method("textDocument/documentHighlight") then
      vim.api.nvim_clear_autocmds {
        group = group,
        buffer = bufnr,
        event = { "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI" },
      }
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = bufnr,
        callback = function()
          if #reference_at_cursor() == 0 then vim.lsp.buf.clear_references() end
        end,
      })
      map("]r", function() jump_reference(1) end, "Next reference")
      map("[r", function() jump_reference(-1) end, "Previous reference")
    end
  end,
})
