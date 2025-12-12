local M = {
    config = {
        echo = true,            -- Echo OpenCode status messages
        decay = 3000,           -- Message decay time in milliseconds (3 seconds)
        interval = 100,         -- Minimum time between echo updates in milliseconds
        spinner_interval = 150, -- Spinner update interval in milliseconds
    },
}

local last_message = ''
local last_operation = ''     -- Keep track of the last operation shown
local last_text_part_id = nil -- Track which text part we're showing
local last_echo = 0
local clear_timer = vim.uv.new_timer()
local spinner_timer = vim.uv.new_timer()
local spinner_frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
local spinner_index = 1
local is_responding = false

local function stop_spinner()
    is_responding = false
    spinner_timer:stop()
    last_operation = ''
    last_text_part_id = nil
end

local function update_spinner_display()
    if not is_responding then
        spinner_timer:stop()
        return
    end

    local frame = spinner_frames[spinner_index]
    spinner_index = spinner_index % #spinner_frames + 1

    local display_text
    if last_operation ~= '' then
        -- Show spinner with last operation
        display_text = frame .. ' ' .. last_operation
    else
        -- Show just thinking message
        display_text = frame .. ' [OpenCode] Thinking...'
    end

    if M.config.echo then
        -- Truncate to available echo space to avoid "Press ENTER" prompt
        -- vim.v.echospace gives us the exact available space in the command line
        local available_space = vim.v.echospace

        -- If text is too long and would be truncated significantly, clear it instead
        -- This allows us to see new updates rather than showing truncated old text
        if #display_text > available_space then
            local truncation_amount = #display_text - available_space
            -- If we're losing more than 30% of the message, clear it
            if truncation_amount > (#display_text * 0.3) then
                last_operation = ''
                display_text = frame .. ' [OpenCode] Thinking...'
            else
                display_text = display_text:sub(1, available_space)
            end
        end

        vim.cmd.redraw()
        vim.api.nvim_echo({ { display_text } }, false, {})
    end
end

local function start_spinner()
    if is_responding then
        return
    end
    is_responding = true
    spinner_index = 1

    spinner_timer:start(0, M.config.spinner_interval, vim.schedule_wrap(update_spinner_display))
end

local function get_last_line(text)
    -- Split by newlines and take the last non-empty line
    local lines = vim.split(text, "\n", { trimempty = false })

    -- Find the last non-empty line
    local last_line = ""
    for i = #lines, 1, -1 do
        local line = vim.trim(lines[i])
        if line ~= "" then
            last_line = line
            break
        end
    end

    -- If no non-empty line found, use the last line anyway
    if last_line == "" and #lines > 0 then
        last_line = vim.trim(lines[#lines])
    end

    -- Clean up extra spaces
    last_line = last_line:gsub("%s+", " ")

    return last_line
end

local function format_tool_params(params)
    -- Format tool parameters into a readable string
    if not params then
        return ""
    end

    -- Common patterns for different tools
    if params.filePath then
        return vim.fn.fnamemodify(params.filePath, ":~:.")
    elseif params.path then
        return vim.fn.fnamemodify(params.path, ":~:.")
    elseif params.pattern then
        return params.pattern
    elseif params.command then
        local cmd = params.command:gsub("\n", " "):gsub("%s+", " ")
        return cmd:sub(1, 50) .. (#cmd > 50 and "..." or "")
    end

    -- Default: show first param value
    for _, v in pairs(params) do
        if type(v) == "string" and v ~= "" then
            return v:sub(1, 50)
        end
    end

    return ""
end

local function format_tool_message(part)
    local tool = part.tool or "tool"
    local state = part.state or {}
    local status = state.status or "running"

    local detail = state.title
    if not detail or detail == "" then
        if status == "error" then
            detail = state.error
        elseif state.metadata and type(state.metadata.status) == "string" then
            detail = state.metadata.status
        end
    end

    local param_hint = ""
    if state.input then
        param_hint = format_tool_params(state.input)
        if (not detail or detail == "") and param_hint ~= "" then
            detail = param_hint
            param_hint = ""
        end
    end

    if not detail or detail == "" then
        if status == "pending" then
            detail = "pending"
        elseif status == "running" then
            detail = "running..."
        elseif status == "completed" then
            detail = "completed"
        elseif status == "error" then
            detail = "error"
        else
            detail = status
        end
    end

    local message = string.format("[OpenCode] %s: %s", tool, detail)
    if param_hint ~= "" then
        message = string.format("%s (%s)", message, param_hint)
    end

    return message
end

local function format_event_message(event)
    -- Handle message parts (tool calls and text)
    if event.type == "message.part.updated" and event.properties and event.properties.part then
        local part = event.properties.part

        -- Text parts - show the actual text OpenCode is outputting
        if part.type == "text" and part.text then
            local text = part.text
            local part_id = part.id

            -- Skip empty text
            if text == "" or text:match("^%s*$") then
                return nil
            end

            -- Update tracking for this text part
            last_text_part_id = part_id

            -- Get the last line of text
            local formatted = get_last_line(text)

            -- Skip if the formatted text is empty
            if formatted == "" then
                return nil
            end

            return "[OpenCode] " .. formatted
        end

        -- Tool events - show the tool status/title when available
        if part.type == "tool" then
            return format_tool_message(part)
        end
    end

    return nil
end

local function on_opencode_event(event)
    -- Debug: log all events to see what we're getting
    -- Uncomment this line to debug what events are coming through:
    -- vim.notify("Event: " .. event.type .. " | " .. vim.inspect(event), vim.log.levels.INFO)

    -- Check for specific events to show
    local message = format_event_message(event)
    if message then
        -- Update the last operation without echoing directly (let spinner handle it)
        last_operation = message
        last_message = message

        -- Make sure spinner is running to show progress
        if not is_responding then
            start_spinner()
        end
        return
    end

    -- Handle generic state changes
    if event.type == "server.connected" then
        stop_spinner()
        clear_timer:stop()
        last_message = ''
        last_operation = ''
        if M.config.echo then
            vim.cmd.redraw()
            vim.api.nvim_echo({ { '' } }, false, {})
        end
    elseif event.type == "session.status" then
        -- Check if session is busy or idle
        if event.properties and event.properties.status then
            if event.properties.status.type == "busy" then
                start_spinner()
            elseif event.properties.status.type == "idle" then
                -- Stop spinner and clear everything immediately
                is_responding = false
                spinner_timer:stop()
                clear_timer:stop()
                last_message = ''
                last_operation = ''
                last_text_part_id = nil

                -- Force clear the echo area immediately
                vim.schedule(function()
                    if M.config.echo then
                        vim.cmd.redraw()
                        vim.api.nvim_echo({ { '' } }, false, {})
                    end
                end)
            end
        end
    elseif event.type == "session.error" then
        stop_spinner()
        last_operation = ''
        if event.properties and event.properties.error then
            local error = event.properties.error
            last_operation = "[OpenCode] Error: " .. (error.message or "Unknown error")
            last_message = last_operation
        end
    end
end

function M.message()
    return last_message
end

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})

    -- Listen to OpenCode events
    vim.api.nvim_create_autocmd("User", {
        pattern = "OpencodeEvent:*",
        callback = function(args)
            ---@type opencode.cli.client.Event
            local event = args.data.event
            if event then
                on_opencode_event(event)
            end
        end,
    })
end

return M
