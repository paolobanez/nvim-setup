return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  opts = {},
  keys = {
    {
      '<leader>ps',
      function() require('persistence').load() end,
      desc = '[P]ersistence: restore [S]ession',
    },
    {
      '<leader>pl',
      function() require('persistence').load({ last = true }) end,
      desc = '[P]ersistence: restore [L]ast session',
    },
    {
      '<leader>pd',
      function() require('persistence').stop() end,
      desc = '[P]ersistence: [D]isable for current session',
    },
  },
}
