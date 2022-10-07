local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  vim.notify("can't find telescope")
  return
end

local pickers_config = {
  layout_strategy = 'vertical',
  layout_config = {
      width = 0.9,
      previewer = true,
  },
}

telescope.setup({
  pickers = {
    buffers = pickers_config,
    find_files = pickers_config,
    live_grep = pickers_config,
  },
  defaults = {
    layout_config = {
      vertical = { width = 0.9 }
    },
  },
})
