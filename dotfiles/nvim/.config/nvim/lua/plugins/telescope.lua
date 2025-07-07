return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
        defaults = {
            layout_strategy = "horizontal",
            layout_config = {
                horizontal = {
                    prompt_position = "top",
                    width = { padding = 0 },
                    height = { padding = 0 },
                    preview_width = 0.75,
                },
            },
            sorting_strategy = "ascending",
            mappings = {
                i = {
                    ["<C-j>"] = require("telescope.actions").move_selection_next,
                    ["<C-k>"] = require("telescope.actions").move_selection_previous,
                },
            },
            border = true,
            borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
            path_display = { "filename_first" },
        },
    },
    keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Telescope find files" } },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>",  { desc = "Telescope live grep" } },
        { "<leader>f/", "<cmd>Telescope live_grep<cr>",  { desc = "Telescope live grep" } },
        { "<leader>fb", "<cmd>Telescope buffers<cr>",    { desc = "Telescope buffers" } },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>",  { desc = "Telescope help tags" } },
    }
}
