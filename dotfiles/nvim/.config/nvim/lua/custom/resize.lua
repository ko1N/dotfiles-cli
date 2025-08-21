local M = {}

M.resize_amount = 6

-- Popup utilities
local debug_output = {}

local function add_debug_line(line)
    table.insert(debug_output, line)
end

local function clear_debug_output()
    debug_output = {}
end

local function show_debug_popup()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'text')
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, debug_output)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win_opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = ' Window Resize Debug Info ',
        title_pos = 'center',
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)
    vim.api.nvim_win_set_option(win, 'wrap', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)

    local opts = { noremap = true, silent = true, buffer = buf }
    vim.keymap.set('n', 'q', '<cmd>close<cr>', opts)
    vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', opts)
    vim.keymap.set('n', '<C-c>', '<cmd>close<cr>', opts)

    vim.api.nvim_echo({ { ' Press q, <Esc>, or <C-c> to close popup ', 'Comment' } }, false, {})

    return win, buf
end

local function debug_windows()
    local current_win = vim.api.nvim_get_current_win()
    local current_pos = vim.api.nvim_win_get_position(current_win)
    local current_width = vim.api.nvim_win_get_width(current_win)
    local current_height = vim.api.nvim_win_get_height(current_win)

    add_debug_line("=== CURRENT WINDOW ===")
    add_debug_line(string.format("Win ID: %d", current_win))
    add_debug_line(string.format("Position: [%d, %d]", current_pos[1], current_pos[2]))
    add_debug_line(string.format("Size: %dx%d", current_width, current_height))
    add_debug_line(string.format("Boundaries: left=%d, right=%d, top=%d, bottom=%d", current_pos[2], current_pos[2] + current_width, current_pos[1], current_pos[1] + current_height))

    local buf = vim.api.nvim_win_get_buf(current_win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
    add_debug_line(string.format("Buffer: %s (ft: %s)", buf_name, filetype))

    local windows = vim.api.nvim_tabpage_list_wins(0)
    add_debug_line("")
    add_debug_line("=== ALL WINDOWS ===")

    for _, win in ipairs(windows) do
        if win ~= current_win then
            local pos = vim.api.nvim_win_get_position(win)
            local width = vim.api.nvim_win_get_width(win)
            local height = vim.api.nvim_win_get_height(win)
            local config = vim.api.nvim_win_get_config(win)
            local buf2 = vim.api.nvim_win_get_buf(win)
            local buf_name2 = vim.api.nvim_buf_get_name(buf2)
            local filetype2 = vim.api.nvim_buf_get_option(buf2, 'filetype')

            add_debug_line(string.format("Win ID: %d", win))
            add_debug_line(string.format("  Position: [%d, %d]", pos[1], pos[2]))
            add_debug_line(string.format("  Size: %dx%d", width, height))
            add_debug_line(string.format("  Boundaries: left=%d, right=%d, top=%d, bottom=%d", pos[2], pos[2] + width, pos[1], pos[1] + height))
            add_debug_line(string.format("  Relative: '%s'", config.relative))
            add_debug_line(string.format("  Buffer: %s (ft: %s)", buf_name2, filetype2))
            add_debug_line("")
        end
    end
end

local function get_neighbors(debug)
    debug = debug or false

    local current_win = vim.api.nvim_get_current_win()
    local current_pos = vim.api.nvim_win_get_position(current_win)
    local current_width = vim.api.nvim_win_get_width(current_win)
    local current_height = vim.api.nvim_win_get_height(current_win)

    local windows = vim.api.nvim_tabpage_list_wins(0)
    local neighbors = {
        left = false,
        right = false,
        above = false,
        below = false,
        left_id = nil,
        right_id = nil,
        above_id = nil,
        below_id = nil,
    }

    local best_left_overlap = -1
    local best_right_overlap = -1
    local best_above_overlap = -1
    local best_below_overlap = -1

    if debug then
        debug_windows()
        add_debug_line("")
        add_debug_line("=== NEIGHBOR DETECTION ===")
    end

    for _, win in ipairs(windows) do
        if win ~= current_win then
            local pos = vim.api.nvim_win_get_position(win)
            local width = vim.api.nvim_win_get_width(win)
            local height = vim.api.nvim_win_get_height(win)
            local config = vim.api.nvim_win_get_config(win)

            if config.relative == "" then
                local current_left = current_pos[2]
                local current_right = current_pos[2] + current_width
                local current_top = current_pos[1]
                local current_bottom = current_pos[1] + current_height

                local other_left = pos[2]
                local other_right = pos[2] + width
                local other_top = pos[1]
                local other_bottom = pos[1] + height

                if debug then
                    local buf2 = vim.api.nvim_win_get_buf(win)
                    local filetype2 = vim.api.nvim_buf_get_option(buf2, 'filetype')
                    add_debug_line(string.format("Checking win %d (ft: %s)", win, filetype2))
                end

                local vertical_overlap = math.max(0, math.min(current_bottom, other_bottom) - math.max(current_top, other_top))
                local horizontal_overlap = math.max(0, math.min(current_right, other_right) - math.max(current_left, other_left))

                local left_adjacent = (other_right >= current_left - 2) and (other_right <= current_left + 2)
                if left_adjacent and vertical_overlap > 0 then
                    if vertical_overlap > best_left_overlap then
                        best_left_overlap = vertical_overlap
                        neighbors.left = true
                        neighbors.left_id = win
                        if debug then add_debug_line("  -> LEFT neighbor found/updated") end
                    end
                elseif debug then
                    add_debug_line(string.format("  -> Not left adjacent: other_right=%d, current_left=%d", other_right, current_left))
                end

                local right_adjacent = (current_right >= other_left - 2) and (current_right <= other_left + 2)
                if right_adjacent and vertical_overlap > 0 then
                    if vertical_overlap > best_right_overlap then
                        best_right_overlap = vertical_overlap
                        neighbors.right = true
                        neighbors.right_id = win
                        if debug then add_debug_line("  -> RIGHT neighbor found/updated") end
                    end
                elseif debug then
                    add_debug_line(string.format("  -> Not right adjacent: current_right=%d, other_left=%d", current_right, other_left))
                end

                local above_adjacent = (other_bottom >= current_top - 2) and (other_bottom <= current_top + 2)
                if above_adjacent and horizontal_overlap > 0 then
                    if horizontal_overlap > best_above_overlap then
                        best_above_overlap = horizontal_overlap
                        neighbors.above = true
                        neighbors.above_id = win
                        if debug then add_debug_line("  -> ABOVE neighbor found/updated") end
                    end
                elseif debug then
                    add_debug_line(string.format("  -> Not above adjacent: other_bottom=%d, current_top=%d", other_bottom, current_top))
                end

                local below_adjacent = (current_bottom >= other_top - 2) and (current_bottom <= other_top + 2)
                if below_adjacent and horizontal_overlap > 0 then
                    if horizontal_overlap > best_below_overlap then
                        best_below_overlap = horizontal_overlap
                        neighbors.below = true
                        neighbors.below_id = win
                        if debug then add_debug_line("  -> BELOW neighbor found/updated") end
                    end
                elseif debug then
                    add_debug_line(string.format("  -> Not below adjacent: current_bottom=%d, other_top=%d", current_bottom, other_top))
                end
            elseif debug then
                add_debug_line(string.format("  -> Skipping floating window %d (relative='%s')", win, config.relative))
            end
        end
    end

    if debug then
        add_debug_line("")
        add_debug_line(string.format("Final neighbors: left=%s(%s), right=%s(%s), above=%s(%s), below=%s(%s)", tostring(neighbors.left), tostring(neighbors.left_id), tostring(neighbors.right), tostring(neighbors.right_id), tostring(neighbors.above), tostring(neighbors.above_id), tostring(neighbors.below), tostring(neighbors.below_id)))
    end

    return neighbors
end

function M.resize_left(debug)
    debug = debug or false
    if debug then clear_debug_output() end

    local neighbors = get_neighbors(debug)

    if debug then
        add_debug_line("")
        add_debug_line("=== RESIZE LEFT ===")
        if neighbors.right then
            add_debug_line("Has right neighbor -> shrink current (move right border left)")
        elseif neighbors.left then
            add_debug_line("Rightmost (no right neighbor) -> expand current (move left border left)")
        else
            add_debug_line("No horizontal neighbors")
        end
    end

    if neighbors.right then
        vim.cmd(string.format("vertical resize -%d", M.resize_amount))
    elseif neighbors.left then
        vim.cmd(string.format("vertical resize +%d", M.resize_amount))
    end

    if debug then show_debug_popup() end
end

function M.resize_right(debug)
    debug = debug or false
    if debug then clear_debug_output() end

    local neighbors = get_neighbors(debug)

    if debug then
        add_debug_line("")
        add_debug_line("=== RESIZE RIGHT ===")
        if neighbors.right then
            add_debug_line("Has right neighbor -> expand current (move right border right)")
        elseif neighbors.left then
            add_debug_line("Rightmost (no right neighbor) -> shrink current (move left border right)")
        else
            add_debug_line("No horizontal neighbors")
        end
    end

    if neighbors.right then
        vim.cmd(string.format("vertical resize +%d", M.resize_amount))
    elseif neighbors.left then
        vim.cmd(string.format("vertical resize -%d", M.resize_amount))
    end

    if debug then show_debug_popup() end
end

function M.resize_up(debug)
    debug = debug or false
    if debug then clear_debug_output() end

    local neighbors = get_neighbors(debug)

    if debug then
        add_debug_line("")
        add_debug_line("=== RESIZE UP ===")
    end

    if neighbors.below then
        if debug then add_debug_line("Has below neighbor - shrinking current window") end
        vim.cmd(string.format("resize -%d", M.resize_amount))
    elseif neighbors.above then
        if debug then add_debug_line("Has above neighbor - expanding current window") end
        vim.cmd(string.format("resize +%d", M.resize_amount))
    elseif debug then
        add_debug_line("No vertical neighbors - no action taken")
    end

    if debug then show_debug_popup() end
end

function M.resize_down(debug)
    debug = debug or false
    if debug then clear_debug_output() end

    local neighbors = get_neighbors(debug)

    if debug then
        add_debug_line("")
        add_debug_line("=== RESIZE DOWN ===")
    end

    if neighbors.below then
        if debug then add_debug_line("Has below neighbor - expanding current window") end
        vim.cmd(string.format("resize +%d", M.resize_amount))
    elseif neighbors.above then
        if debug then add_debug_line("Has above neighbor - shrinking current window") end
        vim.cmd(string.format("resize -%d", M.resize_amount))
    elseif debug then
        add_debug_line("No vertical neighbors - no action taken")
    end

    if debug then show_debug_popup() end
end

function M.debug_neighbors()
    clear_debug_output()
    get_neighbors(true)
    show_debug_popup()
end

function M.debug_resize_left()
    M.resize_left(true)
end

function M.debug_resize_right()
    M.resize_right(true)
end

function M.debug_resize_up()
    M.resize_up(true)
end

function M.debug_resize_down()
    M.resize_down(true)
end

function M.setup(opts)
    opts = opts or {}
    M.resize_amount = opts.resize_amount or 6

    local keymap_opts = { noremap = true, silent = true }

    vim.keymap.set('n', '<C-A-h>', M.resize_left, keymap_opts)
    vim.keymap.set('n', '<C-A-l>', M.resize_right, keymap_opts)
    vim.keymap.set('n', '<C-A-k>', M.resize_up, keymap_opts)
    vim.keymap.set('n', '<C-A-j>', M.resize_down, keymap_opts)

    vim.keymap.set('n', '<leader>rn', M.debug_neighbors, { desc = "Debug window neighbors" })
    vim.keymap.set('n', '<leader>rl', M.debug_resize_left, { desc = "Debug resize left" })
    vim.keymap.set('n', '<leader>rr', M.debug_resize_right, { desc = "Debug resize right" })
    vim.keymap.set('n', '<leader>ru', M.debug_resize_up, { desc = "Debug resize up" })
    vim.keymap.set('n', '<leader>rd', M.debug_resize_down, { desc = "Debug resize down" })
end

return M
