local theme_group = vim.api.nvim_create_augroup("PersistTheme", { clear = true })

local theme_file = vim.fn.stdpath("state") .. "/last-colorscheme"

local function save_theme(name)
  vim.fn.writefile({ name }, theme_file)
end

local function load_theme()
  if vim.fn.filereadable(theme_file) == 1 then
    local lines = vim.fn.readfile(theme_file)
    if lines[1] and lines[1] ~= "" then
      pcall(vim.cmd.colorscheme, lines[1])
      return
    end
  end
  vim.cmd.colorscheme("catppuccin")
end

load_theme()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = theme_group,
  callback = function(args)
    save_theme(args.match)
  end,
})
