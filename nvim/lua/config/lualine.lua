require('lualine').setup({
  options = {
    -- theme = 'OceanicNext',
    theme = 'tokyonight',
    disabled_filetypes = { 'packer', 'NvimTree' },
  },
  sections = {
    -- I don't want any git stuff
    lualine_b = {},

    -- https://github.com/nvim-lualine/lualine.nvim/issues/271
    lualine_c = {
      {
        'filename',
        file_status = true,
        path = 1,
      }
    },
  },
})
