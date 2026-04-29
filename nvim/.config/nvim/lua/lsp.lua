-- ~/.config/nvim-new/lua/lsp.lua
vim.lsp.enable({
  "bashls",
  "gopls",
  "lua_ls",
  "texlab",
  "ts_ls",
  "ty",
  -- "pyrefly",
  "ruff",
})

vim.diagnostic.config({ virtual_text = true })
