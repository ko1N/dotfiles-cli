return {
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup()
    end,
  },

  {
    "cordx56/rustowl",
    dependencies = { "neovim/nvim-lspconfig" },
    event = "VeryLazy",
    config = function()
      local lspconfig = require "lspconfig"
      lspconfig.rustowl.setup {
        trigger = {
          hover = true, -- recommended to use keybinding instead
        },
      }
    end,
  },
}
