local api = vim.api

if vim.loop.os_uname().sysname == 'Linux' then
    -- Disable caps lock while vim is running
    api.nvim_create_autocmd('VimEnter', {
      pattern = "*",
      command = "!setxkbmap -option ctrl:nocaps",
    })

    api.nvim_create_autocmd('VimLeave', {
      pattern = "*",
      command = "!setxkbmap -option",
    })
end

api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = "*.md",
  command = "set wrap",
})
