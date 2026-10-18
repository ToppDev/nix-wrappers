-- Format on save through conform: a dedicated formatter when the project
-- provides one, otherwise the language server. Set `vim.g.autoformat = false`
-- (or `vim.b.autoformat`) to stop formatting on save.
vim.g.autoformat = true

return {
  {
    "conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>lf",
        function() require("conform").format { async = true } end,
        mode = { "n", "v" },
        desc = "Format buffer or selection",
      },
    },
    after = function()
      require("conform").setup {
        formatters_by_ft = {
          nix = { "alejandra" },
          python = { "ruff_organize_imports", "ruff_format" },
          rust = { "rustfmt" },
          c = { "clang-format" },
          cpp = { "clang-format" },
          lua = { "stylua" },
          sh = { "shfmt" },
          bash = { "shfmt" },
          toml = { "taplo" },
          typst = { "typstyle" },
          javascript = { "prettierd", "prettier", stop_after_first = true },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          javascriptreact = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "prettierd", "prettier", stop_after_first = true },
          css = { "prettierd", "prettier", stop_after_first = true },
          html = { "prettierd", "prettier", stop_after_first = true },
        },
        default_format_opts = { lsp_format = "fallback" },
        -- Expected wherever the project brings no formatter
        notify_no_formatters = false,
        format_on_save = function(bufnr)
          if vim.b[bufnr].autoformat == false or not vim.g.autoformat then return end
          return { timeout_ms = 2000 }
        end,
      }
    end,
  },
}
