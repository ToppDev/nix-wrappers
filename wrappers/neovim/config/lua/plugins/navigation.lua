-- Arrow keys to match the tmux side, which binds C-<arrow> to pane switching
-- and passes it through when the pane runs Vim.
vim.g.tmux_navigator_no_mappings = 1

return {
  {
    "vim-tmux-navigator",
    keys = {
      { "<C-Left>", "<cmd>TmuxNavigateLeft<CR>", desc = "Window or pane left" },
      { "<C-Down>", "<cmd>TmuxNavigateDown<CR>", desc = "Window or pane down" },
      { "<C-Up>", "<cmd>TmuxNavigateUp<CR>", desc = "Window or pane up" },
      { "<C-Right>", "<cmd>TmuxNavigateRight<CR>", desc = "Window or pane right" },
    },
  },
}
