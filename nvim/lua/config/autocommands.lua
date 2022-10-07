local api = vim.api

-- Disable caps lock while vim is running
api.nvim_create_autocmd('VimEnter', {
  pattern = "*",
  command = "!setxkbmap -option ctrl:nocaps",
})

api.nvim_create_autocmd('VimLeave', {
  pattern = "*",
  command = "!setxkbmap -option",
})

api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = "*.md",
  command = "set wrap",
})
