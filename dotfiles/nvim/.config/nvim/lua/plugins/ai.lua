return {
  -- cursor for nvim
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      provider = "claude",
      behaviour = {
        enable_cursor_planning_mode = true,
      },
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514",
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_tokens = 32768,
          },
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },

  -- autocomplete
  -- {
  --   "milanglacier/minuet-ai.nvim",
  --   -- cmd = "Minuet",
  --   event = "VeryLazy",
  --   config = function()
  --     require("minuet").setup {
  --       provider = "claude",
  --       provider_options = {
  --         claude = {
  --           max_tokens = 512,
  --           model = "claude-3-5-haiku-latest",
  --           stream = true,
  --         },
  --       },
  --       virtualtext = {
  --         auto_trigger_ft = { "python", "lua", "rust", "go" },
  --         keymap = {
  --           -- accept whole completion
  --           accept = "<A-a>",
  --           -- accept one line
  --           -- accept_line = "<A-a>",
  --           -- accept n lines (prompts for number)
  --           -- accept_n_lines = "<A-z>",
  --           -- Cycle to prev completion item, or manually invoke completion
  --           prev = "<A-Tab>",
  --           -- Cycle to next completion item, or manually invoke completion
  --           -- next = "<A-]>",
  --           -- dismiss = "<A-e>",
  --         },
  --       },
  --     }
  --   end,
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     -- optional, if you are using virtual-text frontend, nvim-cmp is not
  --     -- required.
  --     -- "hrsh7th/nvim-cmp",
  --     -- optional, if you are using virtual-text frontend, blink is not required.
  --     -- "Saghen/blink.cmp",
  --   },
  -- },
}
