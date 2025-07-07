-- load plugins
require("config.lazy")

-- custom modules
require("custom.comment")

-- theme
vim.cmd("colorscheme zaibatsu")
vim.cmd("colorscheme tokyonight-night")

-- vim options
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.wrap = false

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
-- vim.opt.showtabline = 2

vim.opt.scrolloff = 2
vim.opt.sidescrolloff = 4

vim.opt.undofile = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.g.mapleader = " "

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0 -- set to 0 to default to tabstop value

vim.opt.termguicolors = true

-- prevent jumping when lsp is reloading
vim.opt.signcolumn = "yes"

-- TODO: what is this?
vim.opt.cursorlineopt = 'both' -- to enable cursorline!

-- bindings

-- Writing files and closing buffers
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "i", "v" }, "<C-q>", "<cmd>q<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>wq", "<cmd>wq<cr>", { desc = "Write buffer and close" })
vim.keymap.set("n", "<leader>ww", "<cmd>w<cr>", { desc = "Write buffer" })

-- Window navigation
vim.keymap.set({ "n", "i", "v" }, "<C-h>", '<C-w>h', { noremap = true, silent = true })
vim.keymap.set({ "n", "i", "v" }, "<C-j>", '<C-w>j', { noremap = true, silent = true })
vim.keymap.set({ "n", "i", "v" }, "<C-k>", '<C-w>k', { noremap = true, silent = true })
vim.keymap.set({ "n", "i", "v" }, "<C-l>", '<C-w>l', { noremap = true, silent = true })

-- Make visual mode paste replace selected text without overwriting register
vim.keymap.set("x", "p", '"_dP', { noremap = true, silent = true })

-- Visual maps
vim.keymap.set("v", "<leader>r", '"hy:%s/<C-r>h//g<left><left>', { silent = true, desc = "Rename in file" })
vim.keymap.set("v", "<leader>s", ":sort<CR>", { silent = true, desc = "Sort selection" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move selected lines up" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move selected lines down" })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })

-- Show documentation under cursor
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { silent = true, noremap = true, desc = "Code action" })
vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, { silent = true, noremap = true, desc = "Show Docs" })
-- vim.keymap.set({ 'n', 'i' }, '<C-k>', vim.lsp.buf.signature_help, opts_l)

-- Rebind ctrl+c to act as 'Esc' in all modes (except command-line and terminal mode)
vim.keymap.set({ "n", "i", "v", "x", "s" }, "<C-c>", "<Esc>", { noremap = true, silent = true })

-- Prevent escape from being remapped in :term windows
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
