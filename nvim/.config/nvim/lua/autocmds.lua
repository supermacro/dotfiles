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

    if vim.bo[args.buf].filetype == "markdown" then
      vim.wo.conceallevel = 2
      vim.wo.concealcursor = "nc"
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
autocmd("FileType", {
    group = quickfix_group,
    pattern = "qf",
    callback = function(ev)
        vim.keymap.set("n", "<CR>", "<CR>", { buffer = ev.buf })
    end,
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
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

        -- Keep formatting with the rest of the LSP keymaps.
        vim.keymap.set('n', '<space>f', '<cmd>FormatFile<CR>', opts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    end,
})
