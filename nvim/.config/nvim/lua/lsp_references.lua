local M = {}

local method = vim.lsp.protocol.Methods.textDocument_references
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local spinner = {
    timer = nil,
    frame = 1,
    active = false,
}

local function set_status(active)
    spinner.active = active

    if Statusline then
        Statusline.lsp_references_pending = active
        Statusline.lsp_references_frame = active and spinner_frames[spinner.frame] or nil
    end

    vim.cmd("redrawstatus")
end

local function start_spinner()
    if spinner.timer then
        spinner.timer:stop()
        spinner.timer:close()
    end

    spinner.frame = 1
    set_status(true)

    spinner.timer = vim.uv.new_timer()
    spinner.timer:start(120, 120, vim.schedule_wrap(function()
        if not spinner.active then
            return
        end

        spinner.frame = (spinner.frame % #spinner_frames) + 1
        set_status(true)
    end))
end

local function stop_spinner()
    spinner.active = false

    if spinner.timer then
        spinner.timer:stop()
        spinner.timer:close()
        spinner.timer = nil
    end

    set_status(false)
end

local function append_locations(items, result, offset_encoding)
    if not result or vim.tbl_isempty(result) then
        return
    end

    local ok, converted = pcall(vim.lsp.util.locations_to_items, result, offset_encoding)
    if not ok then
        vim.notify(converted, vim.log.levels.ERROR)
        return
    end

    vim.list_extend(items, converted)
end

local function publish_results(items, source_win)
    table.sort(items, function(a, b)
        if a.filename ~= b.filename then
            return a.filename < b.filename
        end

        if a.lnum ~= b.lnum then
            return a.lnum < b.lnum
        end

        return a.col < b.col
    end)

    vim.fn.setqflist({}, " ", {
        title = "LSP references",
        items = items,
    })

    if vim.tbl_isempty(items) then
        vim.notify("No references found", vim.log.levels.INFO)
        return
    end

    vim.cmd("botright copen")
    vim.g.quickfix_preview_target_win = source_win
    vim.cmd("wincmd J")
    vim.cmd("resize 10")
    vim.cmd("normal! gg")
    vim.cmd("doautocmd <nomodeline> CursorMoved")
end

function M.references()
    local bufnr = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })

    if vim.tbl_isempty(clients) then
        vim.notify("No LSP client supports references", vim.log.levels.WARN)
        return
    end

    local items = {}
    local remaining = #clients

    start_spinner()

    for _, client in ipairs(clients) do
        local offset_encoding = client.offset_encoding or "utf-16"
        local params = vim.lsp.util.make_position_params(win, offset_encoding)
        params.context = { includeDeclaration = false }

        client:request(method, params, function(err, result)
            if err then
                vim.schedule(function()
                    vim.notify(err.message or tostring(err), vim.log.levels.ERROR)
                end)
            else
                append_locations(items, result, offset_encoding)
            end

            remaining = remaining - 1
            if remaining == 0 then
                vim.schedule(function()
                    stop_spinner()
                    publish_results(items, win)
                end)
            end
        end, bufnr)
    end
end

return M
