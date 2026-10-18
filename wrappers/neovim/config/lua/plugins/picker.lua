-- Files and grep go through fff: a Rust index ranked by frecency, git status
-- and query history. Everything else (buffers, LSP, diagnostics, git, help…)
-- goes through snacks.picker, which also takes over vim.ui.select.
local function snacks(source, opts)
  return function() require("snacks").picker[source](opts) end
end

return {
  {
    "mini.icons",
    on_require = "mini.icons",
    after = function() require("mini.icons").setup {} end,
  },
  {
    "fff.nvim",
    cmd = { "FFFFind" },
    on_require = "fff",
    keys = {
      { "<leader><leader>", function() require("fff").find_files() end, desc = "Find files" },
      { "<leader>ff", function() require("fff").find_files() end, desc = "Find files" },
      { "<leader>fg", function() require("fff").live_grep() end, desc = "Grep" },
      {
        "<leader>fw",
        function() require("fff").live_grep { query = vim.fn.expand "<cword>" } end,
        desc = "Grep word under cursor",
      },
    },
    after = function()
      require("fff").setup {
        prompt = "> ",
        layout = { prompt_position = "top" },
        -- Picker* groups come from the colorscheme
        hl = {
          normal = "PickerNormal",
          border = "PickerBorder",
          title = "PickerTitle",
          cursor = "PickerCursorLine",
          matched = "PickerMatch",
          grep_match = "PickerMatch",
        },
      }
    end,
  },
  {
    "snacks.nvim",
    -- Loaded once the UI is up, so code actions and other vim.ui.select
    -- prompts use the picker
    event = "DeferredUIEnter",
    on_require = "snacks",
    keys = {
      { "<leader>fb", snacks "buffers", desc = "Buffers" },
      { "<leader>fr", snacks "resume", desc = "Resume last picker" },
      { "<leader>f/", snacks "lines", desc = "Lines in buffer" },
      { "<leader>fh", snacks "help", desc = "Help pages" },
      { "<leader>fk", snacks "keymaps", desc = "Keymaps" },
      { "<leader>fc", snacks "commands", desc = "Commands" },
      { "<leader>fd", snacks "diagnostics_buffer", desc = "Diagnostics in buffer" },
      { "<leader>fD", snacks "diagnostics", desc = "Diagnostics in workspace" },
      { "<leader>fs", snacks "lsp_symbols", desc = "Symbols in buffer" },
      { "<leader>fS", snacks "lsp_workspace_symbols", desc = "Symbols in workspace" },
      { "<leader>fu", snacks "undo", desc = "Undo history" },
      { "<leader>fm", snacks "marks", desc = "Marks" },
      { "<leader>fj", snacks "jumps", desc = "Jumps" },
      { "<leader>fq", snacks "qflist", desc = "Quickfix list" },
      { "<leader>f\"", snacks "registers", desc = "Registers" },
      -- <leader>g otherwise belongs to gitsigns (plugins/git.lua)
      { "<leader>gf", snacks "git_status", desc = "Changed files" },
      { "<leader>gl", snacks "git_log", desc = "Git log" },
      { "<leader>gL", snacks "git_log_file", desc = "Git log for file" },
      { "<leader>gc", snacks "git_branches", desc = "Checkout branch" },
    },
    after = function()
      -- Only the picker; every other snacks module stays off
      require("snacks").setup {
        picker = {
          enabled = true,
          ui_select = true,
          -- No dimmed backdrop behind the picker, as in helix
          layout = { layout = { backdrop = false } },
        },
      }
    end,
  },
}
