-- ~/.config/nvim-new/lua/lsp.lua
vim.lsp.enable({
  "bashls",
  "gopls",
  "lua_ls",
  "texlab",
  "ts_ls",
  "ty",
  "ruff",
})

vim.diagnostic.config({ virtual_text = true })

