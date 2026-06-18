-- ~/.config/nvim-new/lua/lsp.lua
vim.lsp.enable({
  "bashls",
  -- "eslint",
  "gopls",
  "lua_ls",
  "tailwindcss",
  "texlab",
  "ts_ls",
  "ty",
  -- "pyrefly",
  "ruff",
})

vim.diagnostic.config({ virtual_text = true })
