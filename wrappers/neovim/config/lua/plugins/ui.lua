-- Whether a language server already reports this buffer's colors
local function lsp_colors(bufnr)
  return #vim.lsp.get_clients { bufnr = bufnr, method = "textDocument/documentColor" } > 0
end

return {
  {
    "which-key.nvim",
    event = "DeferredUIEnter",
    after = function()
      require("which-key").setup {
        spec = {
          { "<leader>c", group = "Conflict" },
          { "<leader>f", group = "Find" },
          { "<leader>g", group = "Git" },
          { "<leader>l", group = "LSP" },
        },
      }
    end,
  },
  {
    "mini.hipatterns",
    event = "DeferredUIEnter",
    after = function()
      local hipatterns = require "mini.hipatterns"
      hipatterns.setup {
        highlighters = {
          -- Hex colors in any file, with the same swatch as LSP document
          -- colors (lsp.lua); skipped where a server already reports them
          hex_color = hipatterns.gen_highlighter.hex_color {
            style = "inline",
            inline_text = "\u{f0c8} ",
            filter = function(bufnr) return not lsp_colors(bufnr) end,
          },
        },
      }
      -- A server attaching later takes over; drop the duplicate swatches
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserHipatterns", { clear = true }),
        callback = function(args)
          if lsp_colors(args.buf) then hipatterns.update(args.buf) end
        end,
      })
    end,
  },
}
