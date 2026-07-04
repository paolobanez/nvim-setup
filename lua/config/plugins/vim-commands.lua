return {
  'nvim-telescope/telescope.nvim',
  -- reuses already-loaded telescope, this file just adds the keymap
  keys = {
    {
      '<leader>sv',
      function()
        local commands = {
          -- Folds
          { name = 'Toggle Fold',         keys = 'za' },
          { name = 'Open Fold',           keys = 'zo' },
          { name = 'Close Fold',          keys = 'zc' },
          { name = 'Open All Folds',      keys = 'zR' },
          { name = 'Close All Folds',     keys = 'zM' },
          { name = 'Create Fold',         keys = 'zf' },
          -- Navigation
          { name = 'Go to Top',           keys = 'gg' },
          { name = 'Go to Bottom',        keys = 'G' },
          { name = 'Go to Line Start',    keys = '^' },
          { name = 'Go to Line End',      keys = '$' },
          { name = 'Center Screen',       keys = 'zz' },
          { name = 'Jump Back',           keys = '<C-o>' },
          { name = 'Jump Forward',        keys = '<C-i>' },
          -- Editing
          { name = 'Delete Line',         keys = 'dd' },
          { name = 'Yank Line',           keys = 'yy' },
          { name = 'Paste After',         keys = 'p' },
          { name = 'Paste Before',        keys = 'P' },
          { name = 'Undo',                keys = 'u' },
          { name = 'Redo',                keys = '<C-r>' },
          { name = 'Join Lines',          keys = 'J' },
          { name = 'Indent Line',         keys = '>>' },
          { name = 'Outdent Line',        keys = '<<' },
          -- Marks
          { name = 'List Marks',          keys = ':marks<CR>' },
          -- Macros
          { name = 'List Registers',      keys = ':registers<CR>' },
          -- Splits
          { name = 'Split Horizontal',    keys = ':split<CR>' },
          { name = 'Split Vertical',      keys = ':vsplit<CR>' },
          { name = 'Close Split',         keys = ':q<CR>' },
          -- Spelling
          { name = 'Toggle Spell Check',  keys = ':set spell!<CR>' },
          { name = 'Spell Suggest',       keys = 'z=' },
        }

        require('telescope.pickers').new({}, {
          prompt_title = 'Vim Commands',
          finder = require('telescope.finders').new_table({
            results = commands,
            entry_maker = function(entry)
              return {
                value = entry.keys,
                display = entry.name .. '  ' .. entry.keys,
                ordinal = entry.name,
              }
            end,
          }),
          sorter = require('telescope.config').values.generic_sorter({}),
          attach_mappings = function(_, map)
            map('i', '<CR>', function(prompt_bufnr)
              local selection = require('telescope.actions.state').get_selected_entry()
              require('telescope.actions').close(prompt_bufnr)
              vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes(selection.value, true, false, true),
                'n', false
              )
            end)
            return true
          end,
        }):find()
      end,
      desc = '[S]earch [V]im Commands',
    },
  },
}
