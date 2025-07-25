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
    -- Create a new buffer for the popup
    local buf = vim.api.nvim_create_buf(false, true)

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'text')
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)

    -- Add content to buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, debug_output)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    -- Calculate popup size
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Create popup window
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

    -- Set window options
    vim.api.nvim_win_set_option(win, 'wrap', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)

    -- Add keymaps to close popup
    local opts = { noremap = true, silent = true, buffer = buf }
    vim.keymap.set('n', 'q', '<cmd>close<cr>', opts)
    vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', opts)
    vim.keymap.set('n', '<C-c>', '<cmd>close<cr>', opts)

    -- Show instruction at the bottom
    vim.api.nvim_echo({ { ' Press q, <Esc>, or <C-c> to close popup ', 'Comment' } }, false, {})

    return win, buf
end

-- Add debugging function
local function debug_windows()
    local current_win = vim.api.nvim_get_current_win()
    local current_pos = vim.api.nvim_win_get_position(current_win)
    local current_width = vim.api.nvim_win_get_width(current_win)
    local current_height = vim.api.nvim_win_get_height(current_win)

    add_debug_line("=== CURRENT WINDOW ===")
    add_debug_line(string.format("Win ID: %d", current_win))
    add_debug_line(string.format("Position: [%d, %d]", current_pos[1], current_pos[2]))
    add_debug_line(string.format("Size: %dx%d", current_width, current_height))
    add_debug_line(string.format("Boundaries: left=%d, right=%d, top=%d, bottom=%d",
        current_pos[2], current_pos[2] + current_width,
        current_pos[1], current_pos[1] + current_height))

    -- Get buffer info
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
            local buf = vim.api.nvim_win_get_buf(win)
            local buf_name = vim.api.nvim_buf_get_name(buf)
            local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')

            add_debug_line(string.format("Win ID: %d", win))
            add_debug_line(string.format("  Position: [%d, %d]", pos[1], pos[2]))
            add_debug_line(string.format("  Size: %dx%d", width, height))
            add_debug_line(string.format("  Boundaries: left=%d, right=%d, top=%d, bottom=%d",
                pos[2], pos[2] + width, pos[1], pos[1] + height))
            add_debug_line(string.format("  Relative: '%s'", config.relative))
            add_debug_line(string.format("  Buffer: %s (ft: %s)", buf_name, filetype))
            add_debug_line("")
        end
    end
end

-- Enhanced neighbor detection with debugging
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
        below = false
    }

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

                if debug then
                    local buf = vim.api.nvim_win_get_buf(win)
                    local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
                    add_debug_line(string.format("Checking win %d (ft: %s)", win, filetype))
                end

                -- Check for left neighbor - allow for 1-2 column separator
                local left_adjacent = (other_right >= current_left - 2) and (other_right <= current_left + 2)
                if left_adjacent then
                    if not (other_bottom <= current_top or current_bottom <= other_top) then
                        neighbors.left = true
                        if debug then add_debug_line("  -> LEFT neighbor found") end
                    elseif debug then
                        add_debug_line("  -> Left adjacent but no vertical overlap")
                    end
                elseif debug then
                    add_debug_line(string.format("  -> Not left adjacent: other_right=%d, current_left=%d", other_right,
                        current_left))
                end

                -- Check for right neighbor - allow for 1-2 column separator
                local right_adjacent = (current_right >= other_left - 2) and (current_right <= other_left + 2)
                if right_adjacent then
                    if not (other_bottom <= current_top or current_bottom <= other_top) then
                        neighbors.right = true
                        if debug then add_debug_line("  -> RIGHT neighbor found") end
                    elseif debug then
                        add_debug_line("  -> Right adjacent but no vertical overlap")
                    end
                elseif debug then
                    add_debug_line(string.format("  -> Not right adjacent: current_right=%d, other_left=%d",
                        current_right, other_left))
                end

                -- Check for above neighbor - allow for 1-2 row separator
                local above_adjacent = (other_bottom >= current_top - 2) and (other_bottom <= current_top + 2)
                if above_adjacent then
                    if not (other_right <= current_left or current_right <= other_left) then
                        neighbors.above = true
                        if debug then add_debug_line("  -> ABOVE neighbor found") end
                    elseif debug then
                        add_debug_line("  -> Above adjacent but no horizontal overlap")
                    end
                elseif debug then
                    add_debug_line(string.format("  -> Not above adjacent: other_bottom=%d, current_top=%d", other_bottom,
                        current_top))
                end

                -- Check for below neighbor - allow for 1-2 row separator
                local below_adjacent = (current_bottom >= other_top - 2) and (current_bottom <= other_top + 2)
                if below_adjacent then
                    if not (other_right <= current_left or current_right <= other_left) then
                        neighbors.below = true
                        if debug then add_debug_line("  -> BELOW neighbor found") end
                    elseif debug then
                        add_debug_line("  -> Below adjacent but no horizontal overlap")
                    end
                elseif debug then
                    add_debug_line(string.format("  -> Not below adjacent: current_bottom=%d, other_top=%d",
                        current_bottom, other_top))
                end
            elseif debug then
                add_debug_line(string.format("  -> Skipping floating window %d (relative='%s')", win, config.relative))
            end
        end
    end

    if debug then
        add_debug_line("")
        add_debug_line(string.format("Final neighbors: left=%s, right=%s, above=%s, below=%s",
            tostring(neighbors.left), tostring(neighbors.right),
            tostring(neighbors.above), tostring(neighbors.below)))
    end

    return neighbors
end

-- Enhanced resize functions with debugging
function M.resize_left(debug)
    debug = debug or false
    if debug then clear_debug_output() end

    local neighbors = get_neighbors(debug)

    if debug then
        add_debug_line("")
        add_debug_line("=== RESIZE LEFT ===")
        add_debug_line("Logic: When pressing LEFT, we want to move the left border left")
        add_debug_line("- If we have a left neighbor: expand current window (push left border left)")
        add_debug_line("- If we only have a right neighbor: shrink current window (pull left border left)")
    end

    -- Prioritize expanding into left neighbor when available
    if neighbors.left then
        if debug then add_debug_line("Has left neighbor - expanding current window (moving left border left)") end
        vim.cmd(string.format("vertical resize +%d", M.resize_amount))
    elseif neighbors.right then
        if debug then add_debug_line("Has right neighbor (no left) - shrinking current window (moving left border left)") end
        vim.cmd(string.format("vertical resize -%d", M.resize_amount))
    elseif debug then
        add_debug_line("No horizontal neighbors - no action taken")
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
        add_debug_line("Logic: When pressing RIGHT, we want to move the right border right")
        add_debug_line("- If we have a right neighbor: expand current window (push right border right)")
        add_debug_line("- If we only have a left neighbor: shrink current window (pull right border right)")
    end

    -- Prioritize expanding into right neighbor when available
    if neighbors.right then
        if neighbors.left then
            if debug then
                add_debug_line(
                    "Has right and left neighbor - shrinking current window (moving left border right)")
            end
            vim.cmd(string.format("vertical resize -%d", M.resize_amount))
        else
            if debug then
                add_debug_line(
                    "Has right neighbor (no left) - expanding current window (moving right border right)")
            end
            vim.cmd(string.format("vertical resize +%d", M.resize_amount))
        end
    elseif neighbors.left then
        if debug then
            add_debug_line(
                "Has left neighbor (no right) - shrinking current window (moving right border right)")
        end
        vim.cmd(string.format("vertical resize -%d", M.resize_amount))
    elseif debug then
        add_debug_line("No horizontal neighbors - no action taken")
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

-- Debug commands
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

    -- Debug keymaps (optional)
    vim.keymap.set('n', '<leader>rn', M.debug_neighbors, { desc = "Debug window neighbors" })
    vim.keymap.set('n', '<leader>rl', M.debug_resize_left, { desc = "Debug resize left" })
    vim.keymap.set('n', '<leader>rr', M.debug_resize_right, { desc = "Debug resize right" })
    vim.keymap.set('n', '<leader>ru', M.debug_resize_up, { desc = "Debug resize up" })
    vim.keymap.set('n', '<leader>rd', M.debug_resize_down, { desc = "Debug resize down" })
end

return M
