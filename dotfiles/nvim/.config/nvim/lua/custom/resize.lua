-- Tmux-style window resizing for Neovim

local M = {}

M.resize_amount = 6

-- Neighbor detection that accounts for window separators
local function get_neighbors()
    local current_win = vim.api.nvim_get_current_win()
    local current_pos = vim.api.nvim_win_get_position(current_win)
    local current_width = vim.api.nvim_win_get_width(current_win)
    local current_height = vim.api.nvim_win_get_height(current_win)

    local windows = vim.api.nvim_tabpage_list_wins(0)
    local neighbors = {
        left = false,
        right = false,
        above = false,
        below = false
    }

    for _, win in ipairs(windows) do
        if win ~= current_win then
            local pos = vim.api.nvim_win_get_position(win)
            local width = vim.api.nvim_win_get_width(win)
            local height = vim.api.nvim_win_get_height(win)
            local config = vim.api.nvim_win_get_config(win)

            -- Skip floating windows
            if config.relative == "" then
                local current_left = current_pos[2]
                local current_right = current_pos[2] + current_width
                local current_top = current_pos[1]
                local current_bottom = current_pos[1] + current_height

                local other_left = pos[2]
                local other_right = pos[2] + width
                local other_top = pos[1]
                local other_bottom = pos[1] + height

                -- Check for left neighbor - allow for 1-2 column separator
                local left_adjacent = (other_right >= current_left - 2) and (other_right <= current_left + 2)
                if left_adjacent then
                    if not (other_bottom <= current_top or current_bottom <= other_top) then
                        neighbors.left = true
                    end
                end

                -- Check for right neighbor - allow for 1-2 column separator
                local right_adjacent = (current_right >= other_left - 2) and (current_right <= other_left + 2)
                if right_adjacent then
                    if not (other_bottom <= current_top or current_bottom <= other_top) then
                        neighbors.right = true
                    end
                end

                -- Check for above neighbor - allow for 1-2 row separator
                local above_adjacent = (other_bottom >= current_top - 2) and (other_bottom <= current_top + 2)
                if above_adjacent then
                    if not (other_right <= current_left or current_right <= other_left) then
                        neighbors.above = true
                    end
                end

                -- Check for below neighbor - allow for 1-2 row separator
                local below_adjacent = (current_bottom >= other_top - 2) and (current_bottom <= other_top + 2)
                if below_adjacent then
                    if not (other_right <= current_left or current_right <= other_left) then
                        neighbors.below = true
                    end
                end
            end
        end
    end

    return neighbors
end

function M.resize_left()
    local neighbors = get_neighbors()

    if neighbors.right then
        vim.cmd(string.format("vertical resize -%d", M.resize_amount))
    elseif neighbors.left then
        vim.cmd(string.format("vertical resize +%d", M.resize_amount))
    end
end

function M.resize_right()
    local neighbors = get_neighbors()

    if neighbors.right then
        vim.cmd(string.format("vertical resize +%d", M.resize_amount))
    elseif neighbors.left then
        vim.cmd(string.format("vertical resize -%d", M.resize_amount))
    end
end

function M.resize_up()
    local neighbors = get_neighbors()

    if neighbors.below then
        vim.cmd(string.format("resize -%d", M.resize_amount))
    elseif neighbors.above then
        vim.cmd(string.format("resize +%d", M.resize_amount))
    end
end

function M.resize_down()
    local neighbors = get_neighbors()

    if neighbors.below then
        vim.cmd(string.format("resize +%d", M.resize_amount))
    elseif neighbors.above then
        vim.cmd(string.format("resize -%d", M.resize_amount))
    end
end

function M.setup(opts)
    opts = opts or {}
    M.resize_amount = opts.resize_amount or 5

    local keymap_opts = { noremap = true, silent = true }

    vim.keymap.set('n', '<C-A-h>', M.resize_left, keymap_opts)
    vim.keymap.set('n', '<C-A-l>', M.resize_right, keymap_opts)
    vim.keymap.set('n', '<C-A-k>', M.resize_up, keymap_opts)
    vim.keymap.set('n', '<C-A-j>', M.resize_down, keymap_opts)
end

return M
