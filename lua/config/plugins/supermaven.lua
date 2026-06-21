return {
  'supermaven-inc/supermaven-nvim',
  event = 'InsertEnter',
  opts = {
    ignore_filetypes = { 'TelescopePrompt' },
    disable_inline_completion = false,
    disable_keymaps = true,
  },
  config = function(_, opts)
    require('supermaven-nvim').setup(opts)
    local api = require('supermaven-nvim.completion_preview')
    vim.keymap.set('i', '<C-y>', function() api.on_accept_suggestion() end, { silent = true })
    vim.keymap.set('i', '<C-j>', function() api.on_accept_suggestion_word() end, { silent = true })
    vim.keymap.set('i', '<C-]>', function() api.on_dispose_inlay() end, { silent = true })
  end,
}
