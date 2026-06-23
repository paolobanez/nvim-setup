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
local function close_or_bd()
  if #vim.api.nvim_tabpage_list_wins(0) > 1 then vim.cmd('q') else vim.cmd('bd') end
end
vim.keymap.set('n', '<leader>q', close_or_bd, { desc = '[Q]uit buffer' })
vim.keymap.set('n', '<leader>bd', close_or_bd, { desc = '[B]uffer [D]elete' })

-- Diagnostics
vim.keymap.set('n', '<leader>dd', function()
  vim.diagnostic.open_float(nil, { focusable = true })
end, { desc = 'Show line [D]iagnostics' })

-- Oil
vim.keymap.set('n', '<leader>e', '<cmd>e .<CR>', { desc = 'Open current directory/file explorer' })
vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent directory' })

-- Buffer navigation
vim.keymap.set('n', '<S-l>', ':bn<CR>', { desc = 'Switches to next buffer' })
vim.keymap.set('n', '<S-h>', ':bp<CR>', { desc = 'Switches to previous buffer' })

-- Split windows
vim.keymap.set('n', '<C-\\>', '<cmd>vsplit<CR>', { desc = 'Vertical split' })
vim.keymap.set('n', '<C-->', '<cmd>split<CR>', { desc = 'Horizontal split' })

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
