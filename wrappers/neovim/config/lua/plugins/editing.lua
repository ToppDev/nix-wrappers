-- Motions, text objects and editing helpers. All small, so they load once the
-- UI is up and set their keymaps directly.
return {
  {
    "flash.nvim",
    event = "DeferredUIEnter",
    after = function()
      local flash = require "flash"
      flash.setup {}
      vim.keymap.set({ "n", "x", "o" }, "s", flash.jump, { desc = "Flash" })
      -- Visual S belongs to surround
      vim.keymap.set({ "n", "o" }, "S", flash.treesitter, { desc = "Flash tree-sitter node" })
      vim.keymap.set("o", "r", flash.remote, { desc = "Remote flash" })
      vim.keymap.set({ "o", "x" }, "R", flash.treesitter_search, { desc = "Tree-sitter search" })
      vim.keymap.set("c", "<C-s>", flash.toggle, { desc = "Toggle flash in search" })
    end,
  },
  {
    "nvim-treesitter-textobjects",
    event = "DeferredUIEnter",
    after = function()
      require("nvim-treesitter-textobjects").setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local select = require "nvim-treesitter-textobjects.select"
      for key, capture in pairs {
        af = "@function.outer",
        ["if"] = "@function.inner",
        ac = "@class.outer",
        ic = "@class.inner",
        aa = "@parameter.outer",
        ia = "@parameter.inner",
      } do
        vim.keymap.set({ "x", "o" }, key, function() select.select_textobject(capture, "textobjects") end, {
          desc = capture:sub(2):gsub("%.", " "),
        })
      end

      local move = require "nvim-treesitter-textobjects.move"
      local function map_move(lhs, fn, capture, desc)
        vim.keymap.set({ "n", "x", "o" }, lhs, function() move[fn](capture, "textobjects") end, { desc = desc })
      end
      map_move("]f", "goto_next_start", "@function.outer", "Next function start")
      map_move("[f", "goto_previous_start", "@function.outer", "Previous function start")
      map_move("]F", "goto_next_end", "@function.outer", "Next function end")
      map_move("[F", "goto_previous_end", "@function.outer", "Previous function end")
    end,
  },
  {
    "mini.surround",
    event = "DeferredUIEnter",
    after = function()
      -- vim-surround keys, since s is taken by flash: ys{motion}{char} adds,
      -- ds{char} deletes, cs{old}{new} changes, S surrounds a selection
      require("mini.surround").setup {
        mappings = {
          add = "ys",
          delete = "ds",
          replace = "cs",
          find = "",
          find_left = "",
          highlight = "",
          suffix_last = "",
          suffix_next = "",
        },
        search_method = "cover_or_next",
      }
      vim.keymap.del("x", "ys")
      vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true, desc = "Surround" })
      vim.keymap.set("n", "yss", "ys_", { remap = true, desc = "Surround line" })
    end,
  },
  {
    "nvim-autopairs",
    event = "InsertEnter",
    after = function()
      -- check_ts: no pair inside strings and comments, judged by tree-sitter
      require("nvim-autopairs").setup { check_ts = true }
    end,
  },
}
