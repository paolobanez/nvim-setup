return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  config = function()
    require('lualine').setup({
      theme = 'auto',
      options = {
        icons_enabled = false,
        component_separators = '',
        section_separators = '',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          'branch',
          {
            'diff',
            colored = true,
            diff_color = {
              added = { fg = '#216609', gui = 'bold' },
              modified = { fg = '#a55000', gui = 'bold' },
              removed = { fg = '#cc3e28', gui = 'bold' },
            },
            symbols = {
              added = '+',
              modified = '~',
              removed = '-',
            },
          },
        },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'diagnostics' },
        lualine_y = {
          'filetype',
          {
            'lsp_status',
            ignore_lsp = { 'omnisharp' },
          },
        },
        lualine_z = { 'location' },
      },
      tabline = {
        lualine_a = {
          {
            'buffers',
            buffers_color = {
              active = 'TabLineSel',
              inactive = 'TabLine',
            },
          },
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'tabs' },
      },
    })
  end,
}
