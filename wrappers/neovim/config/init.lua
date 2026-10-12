vim.loader.enable()

-- Before any plugin defines mappings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Options ]]
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.scrolloff = 8
vim.o.colorcolumn = "101"
vim.o.mouse = "a"
vim.o.termguicolors = true

vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.breakindent = true

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"

vim.o.undofile = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- [[ Keymaps ]]
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- [[ Plugins ]]
-- Each module in lua/plugins/ returns a list of lze specs. Names are the
-- plugin directory names under pack/*/opt, i.e. the nixpkgs pname.
require("lze").load {
  { import = "plugins.ui" },
}
