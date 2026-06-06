-- ~/.config/nvim-new/lua/autocmds.lua
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight yanked text
local highlight_group = augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({ timeout = 170 })
    end,
    group = highlight_group,
})

local text_wrapping_group = vim.api.nvim_create_augroup("WrapTextBuffers", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function(args)
    -- Window-local options (correct scope)
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.showbreak = "↪ "

    if vim.bo[args.buf].filetype == "markdown" and vim.bo[args.buf].buftype == "" then
      vim.wo.conceallevel = 0
      vim.wo.concealcursor = ""
      vim.wo.colorcolumn = ""
      vim.wo.list = false
      vim.wo.spell = true
    end

    -- Default breakat is already reasonable
    -- Only customize if you have a specific preference
    -- vim.wo.breakat = " ^I!@*-+;:,./?"
  end,
  group = text_wrapping_group,
})

local quickfix_group = augroup('QuickfixMappings', { clear = true })
local quickfix_preview_seq = 0

local function quickfix_preview_reference()
    if vim.bo.filetype ~= "qf" then
        return
    end

    quickfix_preview_seq = quickfix_preview_seq + 1
    local seq = quickfix_preview_seq

    vim.defer_fn(function()
        if seq ~= quickfix_preview_seq or vim.bo.filetype ~= "qf" then
            return
        end

        local qf_win = vim.api.nvim_get_current_win()
        local qf_item = vim.fn.getqflist()[vim.fn.line(".")]

        if not qf_item or qf_item.valid == 0 or qf_item.bufnr == 0 then
            return
        end

        local target_win = vim.g.quickfix_preview_target_win
        if not target_win or not vim.api.nvim_win_is_valid(target_win) then
            target_win = nil
        elseif vim.bo[vim.api.nvim_win_get_buf(target_win)].buftype == "quickfix" then
            target_win = nil
        end

        if not target_win then
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].buftype ~= "quickfix" then
                    target_win = win
                    break
                end
            end
        end

        if not target_win then
            return
        end

        local ok = pcall(vim.api.nvim_win_call, target_win, function()
            vim.api.nvim_set_current_buf(qf_item.bufnr)
            local line_count = vim.api.nvim_buf_line_count(qf_item.bufnr)
            local lnum = math.min(math.max(qf_item.lnum, 1), line_count)
            local line = vim.api.nvim_buf_get_lines(qf_item.bufnr, lnum - 1, lnum, false)[1] or ""
            local col = math.min(math.max(qf_item.col - 1, 0), #line)

            vim.api.nvim_win_set_cursor(0, { lnum, col })
            vim.cmd("normal! zvzz")
        end)

        if ok and vim.api.nvim_win_is_valid(qf_win) then
            vim.api.nvim_set_current_win(qf_win)
        end
    end, 60)
end

autocmd("FileType", {
    group = quickfix_group,
    pattern = "qf",
    callback = function(ev)
        vim.keymap.set("n", "<CR>", "<CR>", { buffer = ev.buf })
    end,
})

autocmd("CursorMoved", {
    group = quickfix_group,
    pattern = "*",
    callback = quickfix_preview_reference,
})

vim.api.nvim_create_user_command("FormatFile", function()
    -- Keep formatting intentionally simple for now: delegate to Neovim's builtin
    -- LSP formatting for the current buffer.
    --
    -- Current limitations:
    -- 1. This does not resolve project-local formatter binaries ahead of globals.
    -- 2. It only works when an attached LSP client supports formatting.
    -- 3. It does not provide custom monorepo-aware routing such as Ruff in
    --    backend/ and Prettier in frontend/ based on the active file path.
    --
    -- If that becomes a real pain point, the next improvement is a custom
    -- resolver that inspects the active buffer's nearest project root and then
    -- shells out to the exact formatter CLI for that subproject.
    vim.lsp.buf.format({ async = false })
end, {
    desc = "Format the current buffer with the attached LSP client",
})

local lsp_group = augroup('LspConfig', { clear = true })
autocmd('LspAttach', {
    group = lsp_group,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end

        if client.name == 'ruff' then
            client.server_capabilities.definitionProvider = false
            client.server_capabilities.declarationProvider = false
        end

        local opts = { buffer = args.buf, silent = true }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gr', require("lsp_references").references, opts)

        -- Keep formatting with the rest of the LSP keymaps.
        vim.keymap.set('n', '<space>f', '<cmd>FormatFile<CR>', opts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    end,
})
