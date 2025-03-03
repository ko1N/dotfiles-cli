require "nvchad.options"

local o = vim.o

o.termguicolors = true

-- o.cursorlineopt ='both' -- to enable cursorline!

o.number = true
o.relativenumber = true

o.wrap = false

o.tabstop = 2
o.shiftwidth = 2
o.showtabline = 2

o.scrolloff = 4
o.sidescrolloff = 6

-- for avante.nvim
o.laststatus = 3

-- for obsidian.nvim
o.conceallevel = 1
