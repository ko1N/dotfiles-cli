return {
    "j-hui/fidget.nvim",
    opts = {
        progress = {
            display = {
                render_limit = 16,
                done_ttl = 0, -- Remove completed items immediately
                done_icon = "✓",
                progress_icon = { pattern = "dots", period = 1 },
            },
        },
        notification = {
            override_vim_notify = true,
            window = {
                y_padding = 1,
            },
        },
    },
}
