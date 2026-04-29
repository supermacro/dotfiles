-- ~/.config/nvim-new/lua/plugins.lua
vim.pack.add({
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
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
  "/%.runtime$",
}

for _, dir in ipairs({ "sandbox", "node_env" }) do
  vim.list_extend(nvim_tree_exclude, always_show_dir(dir))
end

local treesitter_group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true })
local function_only_context_query = [[
(function_declaration) @context
(generator_function_declaration) @context
(method_definition) @context
(
  (lexical_declaration
    (variable_declarator
      value: [
        (arrow_function)
        (function_expression)
      ])) @context
)
(
  (variable_declaration
    (variable_declarator
      value: [
        (arrow_function)
        (function_expression)
      ])) @context
)
]]

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

require("snacks").setup({
    input = { enabled = true },
    picker = {
        enabled = true,
        ui_select = true,
        sources = {
            select = {
                layout = { preset = "select" },
                kinds = {
                    codeaction = {
                        focus = "list",
                        hidden = { "input", "preview" },
                        on_show = function(picker)
                            vim.schedule(function()
                                if picker and not picker.closed and picker.list then
                                    picker.list:view(1, 1)
                                end
                            end)
                        end,
                        layout = {
                            preset = "select",
                            layout = {
                                relative = "cursor",
                                anchor = "NW",
                                row = 1,
                                col = 0,
                                height = 6,
                                min_width = 60,
                                max_width = 100,
                            },
                        },
                    },
                },
            },
        },
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
            previewer = false,
            sorting_strategy = "ascending",
            layout_config = {
                prompt_position = "top",
            },
        },
    }
})
require("nvim-treesitter").install({
  "lua",
  "python",
  "vim",
  "vimdoc",
  "query",
  "markdown",
  "markdown_inline",
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
    "markdown",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  callback = function()
    vim.treesitter.start()
  end,
})

vim.treesitter.query.set("javascript", "context", function_only_context_query)
vim.treesitter.query.set("typescript", "context", function_only_context_query)
vim.treesitter.query.set("tsx", "context", function_only_context_query)
vim.treesitter.query.set("python", "context", [[
(
  (function_definition
    body: (_) @context.end) @context
)
]])

require("treesitter-context").setup({
  max_lines = 1,
  multiline_threshold = 1,
  line_numbers = false,
  trim_scope = "outer",
  on_attach = function(buf)
    local filetype = vim.bo[buf].filetype
    return filetype == "javascript"
      or filetype == "javascriptreact"
      or filetype == "typescript"
      or filetype == "typescriptreact"
      or filetype == "python"
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
