local function highlight_telescope(hl, c)
    local prompt = c.bg
    hl.TelescopeNormal = {
        bg = c.bg,
        fg = c.fg,
    }
    hl.TelescopeBorder = {
        bg = c.bg,
        fg = c.bg,
    }
    hl.TelescopePromptNormal = {
        bg = prompt,
    }
    hl.TelescopePromptBorder = {
        bg = prompt,
        fg = prompt,
    }
    hl.TelescopePromptTitle = {
        bg = c.bg_highlight,
        fg = c.fg,
    }
    hl.TelescopePreviewTitle = {
        bg = c.bg,
        fg = c.bg,
    }
    hl.TelescopeResultsTitle = {
        bg = c.bg,
        fg = c.bg,
    }
    hl.NoiceCmdlinePopupBorder = {
        bg = c.bg,
        fg = c.bg,
    }
end

return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        on_highlights = function(hl, c)
            highlight_telescope(hl, c)
        end,
    },
}
