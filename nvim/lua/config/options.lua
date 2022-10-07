local o = vim.opt
local g = vim.g

o.debug = throw
o.cursorline = true
o.wrap = false
o.number = true
o.relativenumber = true
o.termguicolors = true
o.cmdheight = 2
o.swapfile = false
o.ignorecase = true -- ignore case in search patterns

o.foldmethod="expr"
o.foldexpr="nvim_treesitter#foldexpr()"

-- tab options
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4

-- markdown preview
g.mkdp_auto_close = 0
g.mkdp_theme  = 'light'

-- I wonder if there's a way to do this without VimScript
vim.cmd [[
    autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
    autocmd FileType javascriptreact setlocal shiftwidth=2 tabstop=2
    autocmd FileType typescript setlocal shiftwidth=2 tabstop=2
    autocmd FileType typescriptreact setlocal shiftwidth=2 tabstop=2
    autocmd FileType json setlocal shiftwidth=2 tabstop=2
    autocmd FileType yaml setlocal shiftwidth=2 tabstop=2
    autocmd FileType prisma setlocal shiftwidth=2 tabstop=2

    " treat .mjml files as html
    autocmd BufEnter *.mjml :setlocal filetype=html
]]



---------------------------------------------------
-- tree sitter lesgooo
vim.opt.foldmethod     = 'expr'
vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
--
---WORKAROUND
-- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation
vim.api.nvim_create_autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, {
  group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
  callback = function()
    vim.opt.foldmethod     = 'expr'
    vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
  end
})
---ENDWORKAROUND
