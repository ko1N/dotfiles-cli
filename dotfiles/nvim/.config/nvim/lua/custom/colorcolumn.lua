local api = vim.api

local group = api.nvim_create_augroup("ActiveWindowColorColumn", { clear = true })

COLOR_COLUMN = "80"

local function window_ignore_function(winid)
  local bufid = vim.api.nvim_win_get_buf(winid)
  local buftype = vim.bo[bufid].buftype
  local floating = vim.api.nvim_win_get_config(winid).relative ~= ""
  return buftype ~= "" or floating
end

api.nvim_create_autocmd({ "WinEnter", "WinNew", "BufWinEnter" }, {
  group = group,
  callback = function()
    if not window_ignore_function(api.nvim_get_current_win()) then
      vim.wo.colorcolumn = COLOR_COLUMN
    end
  end,
})

api.nvim_create_autocmd("WinLeave", {
  group = group,
  callback = function()
    vim.wo.colorcolumn = ""
  end,
})
