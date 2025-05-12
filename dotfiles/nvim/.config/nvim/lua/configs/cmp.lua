local config = require "nvchad.configs.cmp"
local cmp = require "cmp"

config.mapping["<CR>"] = cmp.mapping.confirm {
  behavior = cmp.ConfirmBehavior.Insert,
  select = false,
}

config.completion = {
  completeopt = "menu,menuone,noselect,popup",
}

config.preselect = cmp.PreselectMode.None

return config
