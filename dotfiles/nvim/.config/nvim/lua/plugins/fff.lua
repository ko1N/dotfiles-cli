return {
    "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
    -- or if you are using nixos
    -- build = "nix run .#release",
    opts = {
        prompt = '',
        ui_enabled = false,
        layout = {
            width = 0.95,
            height = 0.90, -- TODO: 1.0 does not work
            preview_size = 0.75,
        },
        keymaps = {
            move_up = { '<Up>', '<C-p>', '<C-k>' },
            move_down = { '<Down>', '<C-n>', '<C-j>' },
            close = { '<Esc>', '<C-c>' },
            select = '<CR>',
        },
    },
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
