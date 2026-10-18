-- The mode is shown in the status line instead
vim.o.showmode = false

return {
  {
    "lualine.nvim",
    -- No trigger: loaded during startup so the first frame already has it
    after = function()
      local c = require "ayu_dark_plus"

      -- helix's ui.statusline.* colors: the mode block changes color, the
      -- rest stays on the status line background
      local function mode(bg)
        return {
          a = { fg = c.black, bg = bg, gui = "bold" },
          b = { fg = c.foreground, bg = c.dark_gray },
          c = { fg = c.foreground, bg = c.black },
        }
      end
      local theme = {
        normal = mode(c.blue),
        insert = mode(c.orange),
        visual = mode(c.magenta),
        replace = mode(c.red),
        command = mode(c.yellow),
        terminal = mode(c.green),
        inactive = {
          a = { fg = c.gray, bg = c.black },
          b = { fg = c.gray, bg = c.black },
          c = { fg = c.gray, bg = c.black },
        },
      }

      require("lualine").setup {
        options = {
          theme = theme,
          refresh = {
            events = {
              "WinEnter",
              "BufEnter",
              "BufWritePost",
              "SessionLoadPost",
              "FileChangedShellPost",
              "VimResized",
              "Filetype",
              "CursorMoved",
              "CursorMovedI",
              "ModeChanged",
              -- Recording stops showing on the next refresh after it ends
              "RecordingEnter",
            },
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            -- Branch and counts from gitsigns, which already tracks them
            { "b:gitsigns_head", icon = "" },
            {
              "diff",
              source = function()
                local s = vim.b.gitsigns_status_dict
                if s then return { added = s.added, modified = s.changed, removed = s.removed } end
              end,
            },
            {
              "diagnostics",
              symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
            },
          },
          lualine_c = {
            {
              "filename",
              path = 1,
              symbols = { modified = "●", readonly = "", unnamed = "[No Name]" },
              color = function()
                if vim.bo.modified then return { fg = c.orange } end
              end,
            },
            {
              function()
                local reg = vim.fn.reg_recording()
                return reg ~= "" and "recording @" .. reg or ""
              end,
              color = { fg = c.red, gui = "bold" },
            },
          },
          lualine_x = { "lsp_status", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      }
    end,
  },
}
