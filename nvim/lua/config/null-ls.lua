
local options = {
  prefer_local = "node_modules/.bin"
}

require("null-ls").setup({
  -- https://github.com/jose-elias-alvarez/null-ls.nvim#how-do-i-enable-debug-mode-and-get-debug-output
  -- debug = true,
  sources = {
    require("null-ls").builtins.formatting.stylua,
    require("null-ls").builtins.formatting.prettier.with(options),
    require("null-ls").builtins.diagnostics.eslint.with(options),
  },
})
