require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
-- map("i", "jk", "<ESC>")

map("n", "ge", "G", { noremap = true, silent = true, desc = "Go to end of file" })

-- Make visual mode paste replace selected text without overwriting register
map("x", "p", '"_dP', { noremap = true, silent = true })

-- Writing files and closing buffer shortcuts
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { noremap = true, silent = true })
map({ "n", "i", "v" }, "<C-q>", "<cmd>q<cr>", { noremap = true, silent = true })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Close buffer" })
map("n", "<leader>wq", "<cmd>wq<cr>", { desc = "Write buffer and close" })
map("n", "<leader>ww", "<cmd>w<cr>", { desc = "Write buffer" })

-- Tmux integration
map("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>", { noremap = true, silent = true })
map("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>", { noremap = true, silent = true })
map("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>", { noremap = true, silent = true })
map("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>", { noremap = true, silent = true })
map("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", { noremap = true, silent = true })

-- Advanced window resizing
function _G.window_resize_vert(direction)
  local win_id = vim.api.nvim_get_current_win()

  local win_info = vim.api.nvim_win_get_position(win_id)
  local row = win_info[1]
  local win_height = vim.api.nvim_win_get_height(win_id)
  local screen_height = vim.o.lines - 2 -- screen height - status line

  if (row + win_height) >= screen_height then
    vim.api.nvim_win_set_height(win_id, win_height - direction)
  else
    vim.api.nvim_win_set_height(win_id, win_height + direction)
  end
end

function _G.window_resize_hor(direction)
  local win_id = vim.api.nvim_get_current_win()

  local win_info = vim.api.nvim_win_get_position(win_id)
  local col = win_info[2]
  local win_width = vim.api.nvim_win_get_width(win_id)
  local screen_width = vim.o.columns

  if (col + win_width) >= screen_width then
    vim.api.nvim_win_set_width(win_id, win_width - direction)
  else
    vim.api.nvim_win_set_width(win_id, win_width + direction)
  end
end

map("n", "<c-a-h>", "<cmd>lua window_resize_hor(-3)<CR>", { noremap = true, silent = true })
map("n", "<c-a-j>", "<cmd>lua window_resize_vert(3)<CR>", { noremap = true, silent = true })
map("n", "<c-a-k>", "<cmd>lua window_resize_vert(-3)<CR>", { noremap = true, silent = true })
map("n", "<c-a-l>", "<cmd>lua window_resize_hor(3)<CR>", { noremap = true, silent = true })

-- TODO: move/rotate windows on alt+[] left/right (cycle)

-- telescope defaults
map("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Telescope find files" })
map("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Telescope live grep" })
map("n", "<leader>f/", require("telescope.builtin").live_grep, { desc = "Telescope live grep" })
map("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Telescope buffers" })
map("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Telescope help tags" })

-- visual maps
map("v", "<leader>r", '"hy:%s/<C-r>h//g<left><left>', { silent = true, desc = "Rename in file" })
map("v", "<leader>s", ":sort<CR>", { silent = true, desc = "Sort selection" })
map("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move selected lines up" })
map("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move selected lines down" })
map("v", ">", ">gv", { noremap = true, silent = true })
map("v", "<", "<gv", { noremap = true, silent = true })

-- show documentation under cursor
map("n", "<leader>ca", vim.lsp.buf.code_action, { silent = true, noremap = true, desc = "Code action" })
map("n", "<leader>k", vim.lsp.buf.hover, { silent = true, noremap = true, desc = "Show Docs" })
-- map({ 'n', 'i' }, '<C-k>', vim.lsp.buf.signature_help, opts_l)

-- toggle aerial overview
map("n", "<leader>o", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial View" })
-- map("n", "<leader>ga", "<cmd>AerialNavToggle<CR>", { desc = "Toggle Aerial Navigator" })

-- rebind ctrl+c to act as 'Esc' in all modes (except command-line and terminal mode)
map({ "n", "i", "v", "x", "s" }, "<C-c>", "<Esc>", { noremap = true, silent = true })

-- prevent escape from being remapped in :term windows
map("t", "<Esc>", [[<C-\><C-n>]])
