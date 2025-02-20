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
  --   config = function()
  --     local lspconfig = require "lspconfig"
  --     lspconfig.rustowlsp.setup {
  --       trigger = {
  --         hover = true,
  --       },
  --     }
  --   end,
  -- },
}
