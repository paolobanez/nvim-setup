vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clears search highlight' })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selected lines down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selected lines up' })
vim.keymap.set(
  'n',
  '<leader>s',
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = 'Find and replace word under cursor' }
)
vim.keymap.set('n', '<leader>w', ':w<CR>', { silent = true, desc = '[W]rite file' })
vim.keymap.set('n', '<leader>q', ':bd<CR>', { silent = true, desc = '[Q]uit buffer' })

-- Diagnostics
vim.keymap.set('n', '<leader>d', function()
  vim.diagnostic.open_float(nil, { focusable = true })
end, { desc = 'Show line [D]iagnostics' })

-- Oil
vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent directory' })

-- Buffer navigation
vim.keymap.set('n', '<Tab>', ':bn<CR>', { desc = 'Switches to next buffer' })
vim.keymap.set('n', '<S-Tab>', ':bp<CR>', { desc = 'Switches to previous buffer' })

-- Split window navigation: CTRL+<hjkl>
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move left."<CR>', { desc = 'Disable left arrow' })
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move right"<CR>', { desc = 'Disable right arrow' })
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move up"<CR>', { desc = 'Disable up arrow' })
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move down"<CR>', { desc = 'Disable down arrow' })
