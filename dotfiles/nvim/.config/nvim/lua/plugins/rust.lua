return {
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup()
    end,
  },

  -- {
  --   "cordx56/rustowl",
  --   dependencies = { "neovim/nvim-lspconfig" },
  --   event = "VeryLazy",
  --   config = function()
  --     local lspconfig = require "lspconfig"
  --     lspconfig.rustowl.setup {
  --       trigger = {
  --         hover = false,
  --       },
  --     }
  --   end,
  --   keys = {
  --     {
  --       "<l-o>",
  --       mode = "n",
  --       function()
  --         require("rustowl").rustowl_cursor()
  --       end,
  --       desc = "Rustowl at cursor",
  --     },
  --   },
  -- },
}
