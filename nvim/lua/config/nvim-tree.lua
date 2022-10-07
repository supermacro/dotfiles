local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  vim.notify("can't find nvim-tree")
  return
end

nvim_tree.setup()

