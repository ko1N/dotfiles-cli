local M = {}

local autoformat_disabled = {}

local statusline_state = {}

local function overlay_text(buf)
    local enabled = not autoformat_disabled[buf]
    return enabled and " Autoformat ON " or " Autoformat OFF "
end

local function is_special(buf)
    local ft = vim.bo[buf].filetype
    if ft == "neo-tree" or ft == "neo-tree-popup" or ft == "notify" then
        return true
    end
    local bt = vim.bo[buf].buftype
    if bt == "nofile" or bt == "prompt" or bt == "help" or bt == "terminal" or bt == "quickfix" then
        return true
    end
    return false
end

local function has_window_statusline(winid)
    if not vim.api.nvim_win_is_valid(winid) then
        return false
    end
    local cfg = vim.api.nvim_win_get_config(winid)
    if cfg and cfg.relative ~= "" then
        return false
    end
    local ls = vim.o.laststatus
    if ls == 0 or ls == 3 then
        return false
    end
    if ls == 1 then
        local tab = vim.api.nvim_win_get_tabpage(winid)
        local wins = vim.api.nvim_tabpage_list_wins(tab)
        if #wins < 2 then
            return false
        end
    end
    return true
end

local function should_show(buf, winid)
    if not vim.api.nvim_buf_is_valid(buf) then
        return false
    end
    if is_special(buf) then
        return false
    end
    if not has_window_statusline(winid) then
        return false
    end
    return true
end

local function strip_overlay(sl)
    if not sl or sl == "" then
        return sl
    end
    sl = sl:gsub("%%=%#.-# Autoformat %u+ %%*", "")
    sl = sl:gsub(" Autoformat %u+ ", "")
    return sl
end

local function compose_statusline(base, buf)
    local right = "%=%#Comment#" .. overlay_text(buf) .. "%*"
    local b = base and base or ""
    b = strip_overlay(b)
    if b ~= "" then
        return b .. right
    end
    local fallback = " %f %h%m%r %= %-14.(%l,%c%V%) %P"
    return fallback .. right
end

local function set_statusline(winid)
    if not vim.api.nvim_win_is_valid(winid) then
        statusline_state[winid] = nil
        return
    end
    local buf = vim.api.nvim_win_get_buf(winid)
    if not should_show(buf, winid) then
        local st = statusline_state[winid]
        if st and st.active and vim.api.nvim_win_is_valid(winid) then
            pcall(vim.api.nvim_set_option_value, "statusline", st.orig or "", { win = winid })
            st.active = false
        end
        return
    end
    local st = statusline_state[winid]
    if not st then
        local current = vim.api.nvim_get_option_value("statusline", { win = winid })
        st = { orig = strip_overlay(current), active = false }
        statusline_state[winid] = st
    end
    local base = st.orig
    if base == "" then
        base = vim.o.statusline
    end
    local val = compose_statusline(base, buf)
    local cur = vim.api.nvim_get_option_value("statusline", { win = winid })
    if cur ~= val then
        pcall(vim.api.nvim_set_option_value, "statusline", val, { win = winid })
    end
    st.active = true
end

local function clear_statusline(winid)
    local st = statusline_state[winid]
    if st and st.active then
        if vim.api.nvim_win_is_valid(winid) then
            pcall(vim.api.nvim_set_option_value, "statusline", st.orig or "", { win = winid })
        end
        st.active = false
    end
end

local function update_window(winid)
    set_statusline(winid)
end

local function toggle_autoformat()
    local buf = vim.api.nvim_get_current_buf()
    autoformat_disabled[buf] = not autoformat_disabled[buf]
    local status = autoformat_disabled[buf] and "disabled" or "enabled"
    vim.notify("Autoformat " .. status .. " for buffer " .. buf)
    local wins = vim.fn.win_findbuf(buf)
    for _, w in ipairs(wins) do
        update_window(w)
    end
end

local function check_autoformat_status()
    local buf = vim.api.nvim_get_current_buf()
    local status = autoformat_disabled[buf] and "disabled" or "enabled"
    vim.notify("Autoformat is " .. status .. " for buffer " .. buf)
end

function M.setup()
    local aug = vim.api.nvim_create_augroup("autosave.watermark", { clear = true })

    -- vim.api.nvim_create_autocmd({ "WinNew" }, {
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter", "WinEnter", "FileType" }, {
        group = aug,
        callback = function()
            local win = vim.api.nvim_get_current_win()
            update_window(win)
        end,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        group = aug,
        callback = function(args)
            local winid = tonumber(args.match)
            if winid then
                clear_statusline(winid)
                statusline_state[winid] = nil
            end
        end,
    })
    vim.api.nvim_create_autocmd("BufDelete", {
        callback = function(args)
            autoformat_disabled[args.buf] = nil
        end,
    })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("my.lsp", {}),
        callback = function(args)
            local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
            if not client:supports_method("textDocument/willSaveWaitUntil") and client:supports_method("textDocument/formatting") then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
                    buffer = args.buf,
                    callback = function()
                        if not autoformat_disabled[args.buf] then
                            vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
                        end
                    end,
                })
            end
        end,
    })

    vim.api.nvim_create_user_command("ToggleAutoformat", toggle_autoformat, {
        desc = "Toggle autoformat on save for current buffer",
    })

    vim.api.nvim_create_user_command("AutoformatStatus", check_autoformat_status, {
        desc = "Check autoformat status for current buffer",
    })

    vim.schedule(function()
        update_window(vim.api.nvim_get_current_win())
    end)
end

M.toggle = toggle_autoformat
M.status = check_autoformat_status

return M
