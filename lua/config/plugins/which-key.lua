return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    preset = 'modern',
    delay = 300,
    spec = {
      { '<leader>s', group = '[S]earch' },
      { '<leader>h', group = '[H]unk' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>p', group = '[P]ersistence' },
      { '<leader>r', group = '[R]ename / [R]esume' },
      { '<leader>c', group = '[C]ode' },
      { '<leader>d', group = '[D]iagnostics' },
      { 'g', group = '[G]oto' },
    },
  },
}
