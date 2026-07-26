return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "3.41.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
    opts = {
      -- Slightly wider than neo-tree's default 40 columns.
      window = {
        width = 55,
      },
      filesystem = {
        -- Auto-refresh the tree when files change on disk (OS file watcher).
        use_libuv_file_watcher = true,
      },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    version = 'v0.2.2',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- optional but recommended
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          mappings = {
            -- <Esc> in insert mode enters telescope's normal mode instead of
            -- closing the picker (press it again in normal mode to close).
            i = { ['<esc>'] = function() vim.cmd('stopinsert') end },
          },
        },
      })
      telescope.load_extension('fzf')
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    version = 'v2.1.0',
    opts = {
      -- Custom gutter markers; changedelete/untracked keep gitsigns' defaults.
      signs = {
        add       = { text = '▋' },
        change    = { text = '▋' },
        delete    = { text = '▁' },
        topdelete = { text = '▔' },
      },
    },
  }
}
