return {
  'mason-org/mason.nvim',
  dependencies = {
    'mason-org/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
    'saghen/blink.cmp',
  },
  opts = {},
  config = function(_, opts)
    require('mason').setup(opts)
    require('config.lsp').setup()
  end,
}
