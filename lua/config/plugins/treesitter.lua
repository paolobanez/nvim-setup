return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',

  config = function()
    require('nvim-treesitter').install({
      'c_sharp',
      'javascript',
      'typescript',
      'tsx',
      'json',
      'jsdoc',
      'html',
      'lua',
      'prisma',
      'xml',
    })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = '*',
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
