local M = {}

-- Comment patterns by filetype
local comment_patterns = {
    lua = "--",
    python = "#",
    sql = "--",
    bash = "#",
    sh = "#",
    vim = '"',
    javascript = "//",
    typescript = "//",
    rust = "//",
    go = "//",
    cpp = "//",
    c = "//",
    java = "//",
    php = "//",
    ruby = "#",
    perl = "#",
    yaml = "#",
    toml = "#",
    conf = "#",
    css = "/* */",     -- Block comment example
    html = "<!-- -->", -- Block comment example
}

-- Get comment string for current filetype
local function get_comment_string()
    return comment_patterns[vim.bo.filetype] or "//"
end

-- Check if a line is commented
local function is_commented(line, comment_str)
    local trimmed = line:match("^%s*(.-)%s*$") -- trim whitespace
    return trimmed:sub(1, #comment_str) == comment_str or line:sub(1, #comment_str) == comment_str
end

-- Get the range of lines to operate on
local function get_range(opts)
    if opts.range == 2 then
        -- Visual mode or range specified
        return opts.line1, opts.line2
    else
        -- Normal mode - use current line
        local line_num = vim.api.nvim_win_get_cursor(0)[1]
        return line_num, line_num
    end
end

-- Main toggle function
local function toggle_comment(opts)
    local comment_str = get_comment_string()
    local start_line, end_line = get_range(opts)

    -- Get all lines in range
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

    -- Check if any line is uncommented (if so, we'll comment all)
    local should_comment = false
    for _, line in ipairs(lines) do
        if not is_commented(line, comment_str) and line:match("%S") then -- non-empty, non-whitespace line
            should_comment = true
            break
        end
    end

    -- Process each line
    for i, line in ipairs(lines) do
        local new_line
        if should_comment then
            -- Add comment at the beginning of the line
            new_line = comment_str .. " " .. line
        else
            -- Remove comment from the beginning of the line
            new_line = line:gsub("^" .. vim.pesc(comment_str) .. "%s?", "")
        end

        -- Update the line
        vim.api.nvim_buf_set_lines(0, start_line - 1 + i - 1, start_line + i - 1, false, { new_line })
    end

    -- Clear search highlighting
    vim.cmd("nohlsearch")
end

-- Create the command
vim.api.nvim_create_user_command("ToggleComment", toggle_comment, {
    range = true,
    desc = "Toggle comments on selected lines"
})

-- Set up keymaps
vim.keymap.set({ "n", "v" }, "<leader>/", ":ToggleComment<CR>", {
    desc = "Toggle comment",
    silent = true
})

-- Optional: Export for use in other modules
M.toggle_comment = toggle_comment
M.comment_patterns = comment_patterns

return M
