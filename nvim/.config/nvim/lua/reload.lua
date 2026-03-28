local M = {}

-- This config currently uses several top-level modules such as `plugins` and
-- `keymaps`. Because there is no single namespace prefix yet, reload has to
-- clear a curated list of modules instead of removing one whole subtree.
--
-- Future cleanup:
-- Move config code under `lua/user/...` (or similar), then replace this list
-- with a single namespace-based invalidation pass:
--   if name == "user" or name:sub(1, 5) == "user." then ...
--
-- That approach is more idiomatic and easier to maintain as the config grows.
local module_prefixes = {
  "plugins",
  "configs",
  "keymaps",
  "autocmds",
  "statusline",
  "lsp",
  "theme",
}

local function clear_modules(prefixes)
  for name, _ in pairs(package.loaded) do
    for _, prefix in ipairs(prefixes) do
      if name == prefix or name:sub(1, #prefix + 1) == prefix .. "." then
        package.loaded[name] = nil
        break
      end
    end
  end
end

function M.reload()
  -- Clearing `package.loaded` only affects Lua module caching. It does not
  -- automatically undo side effects from the previous load, so config modules
  -- should remain reload-friendly:
  -- - autocmds in augroups with `clear = true`
  -- - user commands recreated safely
  -- - keymaps defined idempotently
  -- - plugin setup written so re-running it is safe
  clear_modules(module_prefixes)

  -- This config is `init.lua`-based, so re-running the file directly is the
  -- clearest reload path. If this setup ever moves back to `init.vim`, using
  -- `:source $MYVIMRC` would be the more universal entrypoint.
  local ok, err = pcall(dofile, vim.fn.stdpath("config") .. "/init.lua")
  if ok then
    vim.notify("Config reloaded", vim.log.levels.INFO)
    return
  end

  vim.notify("Config reload failed:\n" .. err, vim.log.levels.ERROR)
end

-- Re-loading this module would otherwise try to define the command again.
pcall(vim.api.nvim_del_user_command, "ReloadConfig")
vim.api.nvim_create_user_command("ReloadConfig", M.reload, {
  desc = "Reload Neovim config without restarting",
})

return M
