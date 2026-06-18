---@type vim.lsp.Config
return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'html',
    'css',
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  root_dir = function(bufnr, on_dir)
    local config_root = vim.fs.root(bufnr, {
      'tailwind.config.js',
      'tailwind.config.cjs',
      'tailwind.config.mjs',
      'tailwind.config.ts',
    })

    if config_root then
      on_dir(config_root)
      return
    end

    local package_root = vim.fs.root(bufnr, 'package.json')
    if not package_root then
      return
    end

    local package_json = vim.fn.readfile(package_root .. '/package.json')
    local ok, package = pcall(vim.json.decode, table.concat(package_json, '\n'))
    if ok
        and package
        and (
          package.dependencies and package.dependencies.tailwindcss
          or package.devDependencies and package.devDependencies.tailwindcss
          or package.dependencies and package.dependencies['@tailwindcss/vite']
          or package.devDependencies and package.devDependencies['@tailwindcss/vite']
        )
    then
      on_dir(package_root)
    end
  end,
}
