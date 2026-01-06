return {
    "dmtrKovalenko/fff.nvim",
    build = function()
        -- this will download prebuild binary or try to use existing rustup toolchain to build from source
        -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
        require("fff.download").download_or_build_binary()
    end,
    opts = {
        prompt = '',
        ui_enabled = false,
        layout = {
            width = 0.9,
            height = 0.9, -- TODO: 1.0 does not work
            preview_size = 0.75,
        },
        preview = {
            line_numbers = true,
            wrap_lines = false,
        },
        keymaps = {
            move_up = { '<Up>', '<C-p>', '<C-k>' },
            move_down = { '<Down>', '<C-n>', '<C-j>' },
            close = { '<Esc>', '<C-c>' },
            select = '<CR>',
        },
    },
    -- No need to lazy-load with lazy.nvim.
    -- This plugin initializes itself lazily.
    lazy = false,
    keys = {
        {
            "ff",
            function()
                -- or find_in_git_root() if you only want git files
                require("fff").find_files()
            end,
            desc = "Open file picker",
        },
    },
}
