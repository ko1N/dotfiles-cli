local M = {}

function M.setup()
    local function split_normal()
        local wins = vim.api.nvim_tabpage_list_wins(0)
        if #wins == 1 then
            vim.cmd("vsplit")
        else
            local width = vim.api.nvim_win_get_width(0)
            local height = vim.api.nvim_win_get_height(0)
            if width > (height * 2.5) then
                vim.cmd("vsplit")
            else
                vim.cmd("split")
            end
        end
    end

    local function split_inverse()
        local wins = vim.api.nvim_tabpage_list_wins(0)
        if #wins == 1 then
            vim.cmd("split")
        else
            local width = vim.api.nvim_win_get_width(0)
            local height = vim.api.nvim_win_get_height(0)
            if width > (height * 2.5) then
                vim.cmd("split")
            else
                vim.cmd("vsplit")
            end
        end
    end

    vim.keymap.set("n", "<leader><cr>", split_normal,
        { silent = true, noremap = true, desc = "Split Windows" })
    vim.keymap.set("n", "<C-cr>", split_normal,
        { silent = true, noremap = true, desc = "Split Windows" })
    vim.keymap.set("n", "<leader>\\", split_inverse,
        { silent = true, noremap = true, desc = "Split Windows (inverse)" })
    vim.keymap.set("n", "<C-\\>", split_inverse,
        { silent = true, noremap = true, desc = "Split Windows (inverse)" })

    vim.keymap.set("n", "<C-q>", "<cmd>q<cr>", { desc = "Close buffer" })
end

return M
