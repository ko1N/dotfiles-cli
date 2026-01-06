local M = {}

local fidget = require("fidget.progress")
local progress_handle = nil

-- Configuration
local MAX_LINES = 4

-- Line buffer and state tracking
local line_buffer = {}
local current_text_part_id = nil
local last_text_content = ""
local last_tool_name = nil

local function format_tool_params(params)
    if not params then
        return ""
    end

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

    -- Skip duplicate messages where detail and param_hint are the same
    -- This avoids "read: filename (filename)" duplicates
    if param_hint ~= "" and detail == param_hint then
        return string.format("%s: %s", tool, detail), tool
    end

    local message = string.format("%s: %s", tool, detail)
    if param_hint ~= "" then
        message = string.format("%s (%s)", message, param_hint)
    end

    return message, tool
end

local function update_display()
    local message = table.concat(line_buffer, "\n")

    if not progress_handle then
        progress_handle = fidget.handle.create({
            title = "OpenCode",
            message = message,
        })
    else
        progress_handle.message = message
    end
end

local function add_line(line, tool_name)
    -- Add new line to buffer
    table.insert(line_buffer, line)
    last_tool_name = tool_name

    -- Remove oldest line if we exceed max
    if #line_buffer > MAX_LINES then
        table.remove(line_buffer, 1)
    end

    update_display()
end

local function replace_last_line(line, tool_name)
    -- Replace the last line in the buffer
    if #line_buffer > 0 then
        line_buffer[#line_buffer] = line
        last_tool_name = tool_name
    else
        table.insert(line_buffer, line)
        last_tool_name = tool_name
    end

    update_display()
end

local function update_last_line(text)
    -- Update the last line in the buffer with new text
    if #line_buffer > 0 then
        line_buffer[#line_buffer] = text
    else
        table.insert(line_buffer, text)
    end

    update_display()
end

local function finish_progress()
    if progress_handle then
        -- Delay finish to keep the output visible for a moment
        vim.defer_fn(function()
            if progress_handle then
                progress_handle:finish()
                progress_handle = nil
            end
            line_buffer = {}
            current_text_part_id = nil
            last_text_content = ""
            last_tool_name = nil
        end, 2000) -- 2 seconds delay
    else
        line_buffer = {}
        current_text_part_id = nil
        last_text_content = ""
        last_tool_name = nil
    end
end

local function on_opencode_event(event)
    -- Handle message parts (tool calls and text)
    if event.type == "message.part.updated" and event.properties and event.properties.part then
        local part = event.properties.part

        -- Text parts - show the actual text OpenCode is outputting
        if part.type == "text" and part.text then
            local text = part.text
            local part_id = part.id

            if text ~= "" and not text:match("^%s*$") then
                -- Split text into lines
                local lines = vim.split(text, "\n", { trimempty = false })

                -- Check if this is a new text part or continuation
                if part_id ~= current_text_part_id then
                    -- New part - reset tracking
                    current_text_part_id = part_id
                    last_text_content = ""
                end

                -- Check if we have new content compared to last update
                if text ~= last_text_content then
                    -- If last_text_content is a prefix of text, we're appending
                    if last_text_content ~= "" and vim.startswith(text, last_text_content) then
                        -- Appending to existing content
                        local old_lines = vim.split(last_text_content, "\n", { trimempty = false })
                        local num_old_lines = #old_lines

                        -- If we have more lines now, add the new ones
                        if #lines > num_old_lines then
                            for i = num_old_lines + 1, #lines do
                                local line = vim.trim(lines[i])
                                if line ~= "" then
                                    add_line(line)
                                end
                            end
                        end

                        -- Update the last line if it changed
                        if #lines >= num_old_lines and #lines > 0 then
                            local old_last = num_old_lines > 0 and vim.trim(old_lines[num_old_lines]) or ""
                            local new_last = vim.trim(lines[#lines])
                            if new_last ~= old_last and new_last ~= "" then
                                update_last_line(new_last)
                            end
                        end
                    else
                        -- Complete replacement or first content - add all lines
                        for _, line in ipairs(lines) do
                            local trimmed = vim.trim(line)
                            if trimmed ~= "" then
                                add_line(trimmed)
                            end
                        end
                    end

                    last_text_content = text
                end
            end
        end

        -- Tool events - show the tool status/title
        if part.type == "tool" then
            local message, tool_name = format_tool_message(part)
            if message then
                -- If the last line was the same tool, replace it instead of adding
                if last_tool_name == tool_name and #line_buffer > 0 then
                    replace_last_line(message, tool_name)
                else
                    add_line(message, tool_name)
                end
            end
        end
    end

    -- Handle session state changes
    if event.type == "server.connected" then
        finish_progress()
    elseif event.type == "session.status" then
        if event.properties and event.properties.status then
            if event.properties.status.type == "busy" then
                if #line_buffer == 0 then
                    add_line("Thinking...")
                end
            elseif event.properties.status.type == "idle" then
                finish_progress()
            end
        end
    elseif event.type == "session.error" then
        if event.properties and event.properties.error then
            local error = event.properties.error
            add_line("Error: " .. (error.message or "Unknown error"))
            vim.defer_fn(finish_progress, 3000)
        else
            finish_progress()
        end
    end
end

function M.setup(config)
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
