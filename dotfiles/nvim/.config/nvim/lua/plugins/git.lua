return {
  {
    "tpope/vim-fugitive",
    cmd = "Git",
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup {
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 50, -- 120,
        },
      }
    end,
    keys = {
      {
        "<leader>gd",
        "<cmd>Gitsigns preview_hunk<cr>",
        desc = "Git diff change",
      },
      {
        "<leader>gb",
        "<cmd>Gitsigns toggle_current_line_blame<cr>",
        desc = "Git toggle line blame",
      },
    },
  },

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("neogit").setup()
    end,
    cmd = "Neogit",
    keys = {
      {
        "<leader>gs",
        "<cmd>Neogit<cr>",
        desc = "Neogit status",
      },
    },
  },
}
