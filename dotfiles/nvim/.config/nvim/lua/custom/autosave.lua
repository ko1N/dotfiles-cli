local M = {}

local autoformat_disabled = {}

local ns = vim.api.nvim_create_namespace("autosave_watermark")
local marks = {}

local function overlay_text(buf)
    local enabled = not autoformat_disabled[buf]
    return enabled and " Autoformat ON " or " Autoformat OFF "
end

local function should_show(buf, winid)
    if not vim.api.nvim_buf_is_valid(buf) then
        return false
    end
    local bt = vim.bo[buf].buftype
    if bt == "nofile" or bt == "prompt" or bt == "help" or bt == "terminal" then
        return false
    end
    local cfg = vim.api.nvim_win_get_config(winid)
    if cfg and cfg.relative ~= "" then
        return false
    end
    return true
end

local function topline(winid)
    local l = 1
    pcall(function()
        vim.api.nvim_win_call(winid, function()
            l = vim.fn.line('w0')
        end)
    end)
    return math.max(l - 1, 0)
end

local function clear_mark(winid)
    local m = marks[winid]
    if m and vim.api.nvim_buf_is_valid(m.buf) then
        pcall(vim.api.nvim_buf_del_extmark, m.buf, ns, m.id)
    end
    marks[winid] = nil
end

local function update_mark(winid)
    local buf = vim.api.nvim_win_get_buf(winid)
    if not should_show(buf, winid) then
        clear_mark(winid)
        return
    end
    local prev = marks[winid]
    if prev and prev.buf ~= buf then
        clear_mark(winid)
    end
    local id = prev and prev.id or nil
    local id_new = vim.api.nvim_buf_set_extmark(buf, ns, topline(winid), 0, {
        id = id,
        virt_text = { { overlay_text(buf), "Comment" } },
        virt_text_pos = 'right_align',
        hl_mode = 'combine',
    })
    marks[winid] = { buf = buf, id = id_new }
end

local function update_all()
    local visible = {}
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            visible[win] = true
            update_mark(win)
        end
    end
    for winid, _ in pairs(marks) do
        if not visible[winid] then
            clear_mark(winid)
        end
    end
end

local function toggle_autoformat()
    local buf = vim.api.nvim_get_current_buf()
    autoformat_disabled[buf] = not autoformat_disabled[buf]
    local status = autoformat_disabled[buf] and "disabled" or "enabled"
    print("Autoformat " .. status .. " for buffer " .. buf)
    local wins = vim.fn.win_findbuf(buf)
    for _, w in ipairs(wins) do
        update_mark(w)
    end
end

local function check_autoformat_status()
    local buf = vim.api.nvim_get_current_buf()
    local status = autoformat_disabled[buf] and "disabled" or "enabled"
    print("Autoformat is " .. status .. " for buffer " .. buf)
end

function M.setup()
    local aug = vim.api.nvim_create_augroup('autosave.watermark', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter', 'BufEnter' }, {
        group = aug,
        callback = function()
            update_mark(vim.api.nvim_get_current_win())
        end,
    })

    vim.api.nvim_create_autocmd('WinScrolled', {
        group = aug,
        callback = function()
            update_all()
        end,
    })

    vim.api.nvim_create_autocmd('VimResized', {
        group = aug,
        callback = function()
            update_all()
        end,
    })

    vim.api.nvim_create_autocmd('WinClosed', {
        group = aug,
        callback = function()
            update_all()
        end,
    })


    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('my.lsp', {}),
        callback = function(args)
            local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
            if not client:supports_method('textDocument/willSaveWaitUntil')
                and client:supports_method('textDocument/formatting') then
                vim.api.nvim_create_autocmd('BufWritePre', {
                    group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
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

    vim.api.nvim_create_user_command('ToggleAutoformat', toggle_autoformat, {
        desc = 'Toggle autoformat on save for current buffer'
    })

    vim.api.nvim_create_user_command('AutoformatStatus', check_autoformat_status, {
        desc = 'Check autoformat status for current buffer'
    })

    vim.api.nvim_create_autocmd('BufDelete', {
        callback = function(args)
            autoformat_disabled[args.buf] = nil
        end,
    })

    vim.defer_fn(update_all, 10)
end

M.toggle = toggle_autoformat
M.status = check_autoformat_status

return M
