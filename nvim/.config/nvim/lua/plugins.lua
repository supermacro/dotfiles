-- ~/.config/nvim-new/lua/plugins.lua
vim.pack.add({
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },
  { src = "https://github.com/nvim-tree/nvim-tree.lua" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },

  -- themes
  { src = "https://github.com/catppuccin/nvim" },
})

-- disable netrw, to prevent feature collissions between nvim-tree and netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local function escape_lua_pattern(text)
  return (text:gsub("([^%w])", "%%%1"))
end

local function always_show_dir(name)
  local escaped = escape_lua_pattern(name)
  return {
    string.format("/%s$", escaped),
    string.format("/%s/", escaped),
  }
end

local nvim_tree_exclude = {
  "/%.env$",
  "/%.env%.[^/]+$",
  "/%.data$",
  "/%.db$",
}

for _, dir in ipairs({ "sandbox", "node_env" }) do
  vim.list_extend(nvim_tree_exclude, always_show_dir(dir))
end

local treesitter_group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true })

require("nvim-tree").setup({
    renderer = {
        highlight_git = "name",
    },
    filters = {
        dotfiles = false,
        git_ignored = true,
        custom = {
            "^%.DS_Store$",
            "^Thumbs%.db$",
            "^desktop%.ini$",
        },
        exclude = nvim_tree_exclude,
    },
})

require('gitsigns').setup()
require('mason').setup({})
require('telescope').setup({
    pickers = {
        colorscheme = {
            enable_preview = true,
        },
        find_files = {
            find_command = { "rg", "--files", "--color", "never", "--sort", "path" },
            entry_prefix = "   ",
        },
    }
})
require("nvim-treesitter").install({
  "lua",
  "python",
  "vim",
  "vimdoc",
  "query",
  "javascript",
  "typescript",
  "tsx",
  "json",
  "bash",
})
vim.api.nvim_create_autocmd("FileType", {
  group = treesitter_group,
  pattern = {
    "lua",
    "python",
    "vim",
    "bash",
    "json",
    "javascript",
    "typescript",
    "typescriptreact",
  },
  callback = function()
    vim.treesitter.start()
  end,
})

require('blink.cmp').setup({
    fuzzy = { implementation = 'prefer_rust_with_warning' },
    signature = { enabled = true },
    keymap = {
        preset = "default",
        ["<C-space>"] = {},
        ["<C-p>"] = {},
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-y>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-n>"] = { "select_and_accept" },
        ["<C-b>"] = { "scroll_documentation_down", "fallback" },
        ["<C-f>"] = { "scroll_documentation_up", "fallback" },
        ["<C-l>"] = { "snippet_forward", "fallback" },
        ["<C-h>"] = { "snippet_backward", "fallback" },
        -- ["<C-e>"] = { "hide" },
    },

    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "normal",
    },

    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        }
    },

    cmdline = {
        keymap = { preset = 'inherit' },
        completion = { menu = { auto_show = true } },
    },

    sources = { default = { "lsp" } }
})

