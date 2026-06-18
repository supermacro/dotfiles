local theme_group = vim.api.nvim_create_augroup("SystemTheme", { clear = true })

require("catppuccin").setup({
  custom_highlights = function(colors)
    return {
      ["@markup.heading"] = { fg = colors.blue, style = { "bold" } },
      ["@markup.heading.1.markdown"] = { fg = colors.red, style = { "bold" } },
      ["@markup.heading.2.markdown"] = { fg = colors.peach, style = { "bold" } },
      ["@markup.heading.3.markdown"] = { fg = colors.yellow, style = { "bold" } },
      ["@markup.heading.4.markdown"] = { fg = colors.green, style = { "bold" } },
      ["@markup.heading.5.markdown"] = { fg = colors.teal, style = { "bold" } },
      ["@markup.heading.6.markdown"] = { fg = colors.mauve, style = { "bold" } },
      ["@markup.link"] = { fg = colors.sapphire, style = { "underline" } },
      ["@markup.link.label"] = { fg = colors.blue, style = { "underline" } },
      ["@markup.link.url"] = { fg = colors.overlay1, style = { "italic", "underline" } },
      ["@markup.raw"] = { fg = colors.peach, bg = colors.surface0 },
      ["@markup.raw.block"] = { fg = colors.peach, bg = colors.mantle },
      ["@markup.list"] = { fg = colors.blue },
      ["@markup.list.checked"] = { fg = colors.green, style = { "bold" } },
      ["@markup.list.unchecked"] = { fg = colors.overlay1 },
      ["@markup.quote"] = { fg = colors.teal, style = { "italic" } },
      ["@markup.italic"] = { fg = colors.flamingo, style = { "italic" } },
      ["@markup.strong"] = { fg = colors.maroon, style = { "bold" } },
      ["@markup.strikethrough"] = { fg = colors.overlay1, style = { "strikethrough" } },
      CursorLineNr = { fg = colors.base, bg = colors.blue, style = { "bold" } },
    }
  end,
})

local function macos_appearance()
  if vim.uv.os_uname().sysname ~= "Darwin" then
    return nil
  end

  local output = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
  if vim.v.shell_error == 0 and output:match("Dark") then
    return "dark"
  end

  return "light"
end

local function time_of_day_appearance()
  local hour = tonumber(os.date("%H"))
  return (hour >= 8 and hour < 20) and "light" or "dark"
end

local function system_colorscheme()
  local appearance = macos_appearance() or time_of_day_appearance()
  return appearance == "light" and "catppuccin-latte" or "catppuccin-mocha"
end

local function apply_system_theme()
  local colorscheme = system_colorscheme()
  if vim.g.colors_name == colorscheme then
    return
  end

  vim.cmd.colorscheme(colorscheme)
end

apply_system_theme()

vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
  group = theme_group,
  callback = apply_system_theme,
})

local theme_timer = vim.uv.new_timer()
theme_timer:start(60000, 60000, function()
  vim.schedule(apply_system_theme)
end)
