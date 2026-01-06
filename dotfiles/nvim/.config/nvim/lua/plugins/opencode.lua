return {
    "NickvanDyke/opencode.nvim",
    dependencies = {
        -- Recommended for `ask()` and `select()`.
        -- Required for `snacks` provider.
        ---@module 'snacks'
        -- { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {}, opts = {} } },
    },
    keys = {
        { "<leader>co", function() require("opencode").ask("@this: ", { submit = true }) end,      mode = { "n", "x" }, desc = "OpenCode: Ask" },
        { "<leader>cp", function() require("opencode").select() end,                               mode = { "n", "x" }, desc = "OpenCode: Execute..." },
        { "<leader>ci", function() require("opencode").prompt("implement", { submit = true }) end, mode = { "n", "x" }, desc = "OpenCode: Implement function" },

        -- { "ga", function() require("opencode").prompt("@this") end, mode = { "n", "x" }, desc = "Add to opencode" },
        -- { "<C-.>", function() require("opencode").toggle() end, mode = { "n", "t" }, desc = "Toggle opencode" },
        -- { "<S-C-u>", function() require("opencode").command("session.half.page.up") end, mode = "n", desc = "opencode half page up" },
        -- { "<S-C-d>", function() require("opencode").command("session.half.page.down") end, mode = "n", desc = "opencode half page down" },
        -- Restore default increment/decrement behavior
        -- { "+", "<C-a>", mode = "n", desc = "Increment", noremap = true },
        -- { "-", "<C-x>", mode = "n", desc = "Decrement", noremap = true },
    },
    config = function()
        ---@type opencode.Opts
        vim.g.opencode_opts = {
            -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
        }

        -- Required for `opts.events.reload`.
        vim.o.autoread = true
    end,
}
