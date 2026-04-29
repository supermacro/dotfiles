local keymap = vim.keymap.set

local function end_of_line_col(lnum)
    return math.max(vim.fn.col({ lnum, "$" }) - 2, 0)
end

local function w_without_crossing_lines()
    local target_line = vim.api.nvim_win_get_cursor(0)[1]

    for _ = 1, vim.v.count1 do
        vim.cmd.normal({ args = { "w" }, bang = true })

        local cursor = vim.api.nvim_win_get_cursor(0)
        if cursor[1] ~= target_line then
            vim.api.nvim_win_set_cursor(0, { target_line, end_of_line_col(target_line) })
            break
        end
    end
end

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
keymap("n", "w", w_without_crossing_lines, { silent = true, desc = "Move to next word without crossing lines" })

-- vim.pack stuff
keymap("n", "<leader>ps", "<cmd>lua vim.pack.update()<CR>")
keymap("n", "<leader>rr", "<cmd>ReloadConfig<CR>")
keymap("n", "<leader>d", function()
    vim.diagnostic.open_float(nil, {
        focus = false,
        scope = "line",
        border = "rounded",
        source = "if_many",
    })
end, { desc = "Open diagnostic float" })

-- Niceties
keymap("n", "<CR>", ":wa<CR>")
keymap('n', '<leader>b', ':b#<CR>') -- go to previously-visited buffer
keymap("n", "zc", "zC", { desc = "Close fold recursively" })
keymap("n", "zo", "zO", { desc = "Open fold recursively" })



-- NvimTree Aliases
keymap("n", "<leader>e", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle NvimTree and find current file" })


-- Telescope Aliases
local builtin = require('telescope.builtin')
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")

local function live_grep(opts)
    opts = opts or {}

    builtin.live_grep({
        cwd = opts.cwd,
        additional_args = function ()
            return { "--fixed-strings" }
        end,
        layout_config = {
            width = 0.99,
            height = 0.99,
            preview_width = 0.4,
        },
    })
end

local function directory_find_command(root)
    if vim.fn.executable("fd") == 1 then
        return { "fd", "--type", "d", "--hidden", "--follow", "--exclude", ".git", ".", root }
    end

    return { "find", root, "-type", "d", "-not", "-path", "*/.git/*" }
end

local function relative_directory_display(path)
    local relative = vim.fn.fnamemodify(path, ":.")
    if relative == "." then
        return "/"
    end

    if vim.startswith(relative, "./") then
        relative = relative:sub(2)
    elseif not vim.startswith(relative, "/") then
        relative = "/" .. relative
    end

    if not vim.endswith(relative, "/") then
        relative = relative .. "/"
    end

    return relative
end

local function pick_grep_directory()
    local root = vim.loop.cwd()

    pickers.new({}, {
        prompt_title = "Grep Directories",
        finder = finders.new_oneshot_job(directory_find_command(root), {
            cwd = root,
            entry_maker = function(line)
                local absolute = vim.fn.fnamemodify(line, ":p")
                return {
                    value = absolute,
                    ordinal = relative_directory_display(absolute),
                    display = relative_directory_display(absolute),
                }
            end,
        }),
        previewer = false,
        sorter = conf.file_sorter({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                if not selection or not selection.value then
                    return
                end

                live_grep({ cwd = selection.value })
            end)

            return true
        end,
    }):find()
end

keymap('n', '<leader>ff', builtin.find_files)
keymap('n', '<leader>fg', function ()
    live_grep()
end, { desc = "Live grep from cwd" })
keymap('n', '<leader>fG', function ()
    pick_grep_directory()
end, { desc = "Pick directory and live grep" })
keymap('n', '<leader>fb', ':Telescope buffers<CR>')
keymap('n', '<leader>fh', ':Telescope help_tags<CR>')
