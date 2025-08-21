return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        lazy = false,
        config = function()
            vim.keymap.set("n", "<C-e>", "<Cmd>Neotree reveal right<CR>")

            require("neo-tree").setup({
                filesystem = {
                    window = {
                        fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
                            ["<C-j>"] = "move_cursor_down",
                            ["<C-k>"] = "move_cursor_up",
                            ["<C-c>"] = "close",
                        },
                    },
                },
            })
        end,
    },
    {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
        },
        config = function()
            require("lsp-file-operations").setup()
        end,
    },
    {
        "s1n7ax/nvim-window-picker",
        version = "2.*",
        config = function()
            require("window-picker").setup({
                filter_rules = {
                    include_current_win = false,
                    autoselect_one = true,
                    -- filter using buffer options
                    bo = {
                        -- if the file type is one of following, the window will be ignored
                        filetype = { "neo-tree", "neo-tree-popup", "notify" },
                        -- if the buffer type is one of following, the window will be ignored
                        buftype = { "terminal", "quickfix" },
                    },
                },
            })
        end,
    },
}
