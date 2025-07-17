local M = {}

-- Table to track buffers where autoformat is disabled
local autoformat_disabled = {}

-- Function to toggle autoformat for current buffer
local function toggle_autoformat()
    local buf = vim.api.nvim_get_current_buf()
    autoformat_disabled[buf] = not autoformat_disabled[buf]

    local status = autoformat_disabled[buf] and "disabled" or "enabled"
    print("Autoformat " .. status .. " for buffer " .. buf)
end

-- Function to check current autoformat status
local function check_autoformat_status()
    local buf = vim.api.nvim_get_current_buf()
    local status = autoformat_disabled[buf] and "disabled" or "enabled"
    print("Autoformat is " .. status .. " for buffer " .. buf)
end

-- Setup function to initialize autoformat behavior
function M.setup()
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('my.lsp', {}),
        callback = function(args)
            local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
            -- Auto-format ("lint") on save.
            -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
            if not client:supports_method('textDocument/willSaveWaitUntil')
                and client:supports_method('textDocument/formatting') then
                vim.api.nvim_create_autocmd('BufWritePre', {
                    group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
                    buffer = args.buf,
                    callback = function()
                        -- Check if autoformat is disabled for this buffer
                        if not autoformat_disabled[args.buf] then
                            vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
                        end
                    end,
                })
            end
        end,
    })

    -- Create user command
    vim.api.nvim_create_user_command('ToggleAutoformat', toggle_autoformat, {
        desc = 'Toggle autoformat on save for current buffer'
    })

    -- Create status command
    vim.api.nvim_create_user_command('AutoformatStatus', check_autoformat_status, {
        desc = 'Check autoformat status for current buffer'
    })

    -- Optional: Create a keybind (uncomment the line below and customize the key)
    -- vim.keymap.set('n', '<leader>tf', toggle_autoformat, { desc = 'Toggle autoformat' })

    -- Clean up disabled buffers when they're deleted
    vim.api.nvim_create_autocmd('BufDelete', {
        callback = function(args)
            autoformat_disabled[args.buf] = nil
        end,
    })
end

-- Export the toggle function for manual use
M.toggle = toggle_autoformat
M.status = check_autoformat_status

return M
