return {
  {
    "gitsigns.nvim",
    -- Attaches to every buffer already open when it loads
    event = "DeferredUIEnter",
    after = function()
      require("gitsigns").setup {
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        on_attach = function(bufnr)
          local gs = require "gitsigns"
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          map("n", "]g", function()
            if vim.wo.diff then return vim.cmd.normal { "]c", bang = true } end
            gs.nav_hunk "next"
          end, "Next hunk")
          map("n", "[g", function()
            if vim.wo.diff then return vim.cmd.normal { "[c", bang = true } end
            gs.nav_hunk "prev"
          end, "Previous hunk")

          -- stage_hunk toggles: run it again on a staged hunk to unstage it
          map("n", "<leader>gs", gs.stage_hunk, "Stage or unstage hunk")
          map("v", "<leader>gs", function()
            gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
          end, "Stage or unstage lines")
          map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
          map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
          map("v", "<leader>gr", function()
            gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
          end, "Reset lines")
          map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
          map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>gt", gs.preview_hunk_inline, "Show deleted lines inline")
          map("n", "<leader>gb", function() gs.blame_line { full = true } end, "Blame line")
          map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle line blame")
          map("n", "<leader>gd", gs.diffthis, "Diff against index")

          map({ "o", "x" }, "ih", gs.select_hunk, "Hunk")
        end,
      }
    end,
  },
}
