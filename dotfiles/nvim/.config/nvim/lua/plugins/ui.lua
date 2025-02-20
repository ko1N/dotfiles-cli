return {
  {
    "sphamba/smear-cursor.nvim",
    opts = {
      cursor_color = "#aaaaaa",
      legacy_computing_symbols_support = true,
      smear_insert_mode = true,
    },
    event = { "WinEnter" },
  },

  {
    "nvim-zh/colorful-winsep.nvim",
    config = function()
      require("colorful-winsep").setup {
        hi = {
          --bg = "#282C34",
          fg = "#61AFEF",
        },
      }
    end,
    event = { "WinLeave" },
  },

  {
    "levouh/tint.nvim",
    config = function()
      require("tint").setup {
        tint = -25,
        saturation = 0.75,
        transforms = require("tint").transforms.SATURATE_TINT,
        tint_background_colors = false,
        highlight_ignore_patterns = { "WinSeparator", "Status.*" },
        window_ignore_function = function(winid)
          -- local bufid = vim.api.nvim_win_get_buf(winid)
          -- local buftype = vim.api.nvim_buf_get_option(bufid, "buftype")
          local floating = vim.api.nvim_win_get_config(winid).relative ~= ""
          --return buftype == "terminal" or floating
          return floating
        end,
      }
    end,
    event = { "WinLeave" },
  },

  {
    "stevearc/aerial.nvim",
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("aerial").setup {
        backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
        on_attach = function(bufnr)
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      }
    end,
    event = { "WinEnter" },
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      rainbow = {
        -- enable colors
        enabled = true,
      },
      modes = {
        search = {
          -- enable search via / and ?
          enabled = true,
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      -- {
      --   "<c-s>",
      --   mode = { "c" },
      --   function()
      --     require("flash").toggle()
      --   end,
      --   desc = "Toggle Flash Search",
      -- },
    },
  },

  {
    "sontungexpt/stcursorword",
    event = "VeryLazy",
    config = function()
      require("stcursorword").setup {
        max_word_length = 100,
        min_word_length = 3,
        excluded = {
          filetypes = {
            "TelescopePrompt",
          },
          buftypes = {},
          patterns = {},
        },
        highlight = {
          underline = true,
          fg = nil,
          bg = nil, -- "#282C34",
        },
      }
    end,
  },

  -- {
  --   "m4xshen/smartcolumn.nvim",
  --   event = "VeryLazy",
  --   opts = {},
  -- },

  {
    "rcarriga/nvim-notify",
    lazy = false,
    config = function()
      require("notify").setup {
        stages = "fade_in_slide_out",
        timeout = 2000,
        fps = 60,
        render = "default",
      }

      -- override default vim notifications
      vim.notify = require "notify"
    end,
  },

  {
    "stevearc/dressing.nvim",
    opts = {},
  },
}
