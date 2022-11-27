local options = {
  prefer_local = "node_modules/.bin"
}

local builtins = require("null-ls").builtins

require("null-ls").setup({
  -- https://github.com/jose-elias-alvarez/null-ls.nvim#how-do-i-enable-debug-mode-and-get-debug-output
  -- debug = true,
  sources = {
    builtins.formatting.stylua,
    builtins.diagnostics.eslint_d.with(options),
  },
})
