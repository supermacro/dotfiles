-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

-- local use = require('packer').use

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- better cursor
  use {
    'gen740/SmoothCursor.nvim',
    commit = '67aa23520e16b4a64d56f33885653aad481b3626',
    config = function()
      require('smoothcursor').setup()
    end
  }

  -- 🌳 sitter lesgo (charles leclerc voice)
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  }

  -- noice
  use {
    'lewis6991/gitsigns.nvim',
    tag = 'v0.5',
    config = function()
      require('gitsigns').setup()
    end
  }

  -- Themes & Syntax Stuff
  use 'ayu-theme/ayu-vim'

  -- Fuzzy Finding Things
  use {                                                        
    'nvim-telescope/telescope.nvim',                           
    requires = {                                               
      {'nvim-lua/popup.nvim'},                                 
      {'nvim-lua/plenary.nvim'},                               
      {'nvim-telescope/telescope-fzf-native.nvim', run="make"},
      {'nvim-telescope/telescope-symbols.nvim'},               
    },                                                         
  }

  use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  })

  -- LSP Stuff
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'

  -- Autocompletion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'saadparwaiz1/cmp_luasnip'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-nvim-lua'

    -- Snippets
  use 'L3MON4D3/LuaSnip'
  use 'rafamadriz/friendly-snippets'

  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons',
    },
    tag = 'nightly' -- optional, updated every week. (see issue #1193)
  }
end)
