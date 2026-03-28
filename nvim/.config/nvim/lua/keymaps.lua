local keymap = vim.keymap.set

-- assuming leader is \ by default, which I like
-- vim.g.mapleader = " "

keymap("n", "<space>", "<Nop>")

keymap({ "n", "i", "v", "c" }, "<F1>", function()
    vim.fn.jobstart({ "afplay", "/System/Library/Sounds/Ping.aiff" }, { detach = true })
end, { silent = true, desc = "Play macOS ping sound" })

keymap("n", "j", function()
    return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "j" or "gj"
end, { expr = true, silent = true }) -- Move down, but use 'gj' if no count is given
keymap("n", "k", function()
    return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "k" or "gk"
end, { expr = true, silent = true }) -- Move up, but use 'gk' if no count is given

-- vim.pack stuff
keymap("n", "<leader>ps", "<cmd>lua vim.pack.update()<CR>")
keymap("n", "<leader>rr", "<cmd>ReloadConfig<CR>")

-- Niceties
keymap("n", "<CR>", ":wa<CR>")
keymap('n', '<leader>b', ':b#<CR>') -- go to previously-visited buffer



-- NvimTree Aliases
keymap("n", "<leader>e", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle NvimTree and find current file" })


-- Telescope Aliases
local builtin = require('telescope.builtin')
keymap('n', '<leader>ff', builtin.find_files)
keymap('n', '<leader>fg', function ()
    builtin.live_grep({
        additional_args = function ()
            return { "--fixed-strings" }
        end,
        layout_config = {
            width = 0.99,
            height = 0.99,
            preview_width = 0.4,
        },
    })
end)
keymap('n', '<leader>fb', ':Telescope buffers<CR>')
keymap('n', '<leader>fh', ':Telescope help_tags<CR>')
