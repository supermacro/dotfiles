-- Modes
--   normal_mode = "n"
--   insert_mode = "i"
--   visual_mode = "v"
--   visual_block_mode = "x"
--   term_mode = "t"
--   command_mode = "c"

local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

keymap('n', '<leader>h', ':echo "hello!"<CR>', {desc = 'Say hello'})

-- Some basics
keymap('n', '<CR>', ':wa<CR>', opts)
keymap('n', '<esc>', ':noh<CR>', opts)
-- copy path to file
keymap('n', 'cp', ':let @+ = expand("%")<CR>', opts)

-- NvimTree Aliases
keymap('n', '<leader>e', ':NvimTreeToggle<CR>', opts)
keymap('n', '<leader>f', ':NvimTreeFindFile<CR>', opts)

-- quickfix list
-- https://freshman.tech/vim-quickfix-and-location-list/
keymap('n', '<space>n', ':cn<CR>', opts)
keymap('n', '<space>p', ':cp<CR>', opts)

-- Telescope Aliases
keymap('n', '<leader>ff', ':Telescop find_files<CR>', opts)
keymap('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
keymap('n', '<leader>fb', ':Telescope buffers<CR>', opts)
keymap('n', '<leader>fh', ':Telescope help_tags<CR>', opts)


-- Niceties
keymap('n', '<leader>b', ':b#<CR>', opts) -- go to previously-visited buffer
keymap('n', '<leader>w', '3<C-w>>', opts) -- widen window by 3 characters at a time
keymap('n', '<leader>y', ":let @+=expand('%:p')<CR>", opts) -- widen window by 3 characters at a time

-- https://vim.fandom.com/wiki/Move_cursor_by_display_lines_when_wrapping
keymap('n', 'j', 'gj', opts)
keymap('n', 'k', 'gk', opts)




-- x11 bruh
-- https://vim.fandom.com/wiki/GNU/Linux_clipboard_copy/paste_with_xclip
keymap('v', '<F6>', ':!xclip -f -sel clip<CR>', opts)

-- the below mapping is not working :'(
-- keymap('i', '<F7>', ':-1r !xclip -o -sel clip<CR>', opts)

-- Better window navigation
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)

local close_window_opts = table.shallow_copy(opts)
close_window_opts["desc"] = "Close current window"
keymap('n', '<C-x>', ':close<CR>', close_window_opts)


keymap('n', '<C-Up>', ':resize -2<CR>', opts)
keymap('n', '<C-Down>', ':resize +2<CR>', opts)
keymap('n', '<C-Left>', ':vertical resize -2<CR>', opts)
keymap('n', '<C-Right>', ':vertical resize +2<CR>', opts)
