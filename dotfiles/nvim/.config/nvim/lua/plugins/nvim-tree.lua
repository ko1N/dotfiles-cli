return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local function nvim_tree_attach(bufnr)
            local api = require("nvim-tree.api")
            api.config.mappings.default_on_attach(bufnr)
            vim.keymap.del("n", "<C-e>", { buffer = bufnr })
        end

        require("nvim-tree").setup({
            on_attach = nvim_tree_attach
        })

        local function nvim_tree_toggle()
            local nvim_tree = require("nvim-tree.api")
            local view = require("nvim-tree.view")

            if vim.api.nvim_get_current_buf() == view.get_bufnr() then
                nvim_tree.tree.close()
            else
                -- Focus also opens the tree
                nvim_tree.tree.focus()
            end
        end

        vim.keymap.set("n", "<C-e>", nvim_tree_toggle, { silent = true, noremap = true, desc = "Toggle NvimTree" })
    end,
}
