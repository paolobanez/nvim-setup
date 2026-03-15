return {
  'nvim-telescope/telescope.nvim',
  tag = 'v0.2.1',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  module = 'telescope',

  config = function()
    require('telescope').setup({
      defaults = {
        file_ignore_patterns = { 'undodir/.*', 'node_modules', '.next', 'dist', '.git', '.turbo' },
      },

      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = 'smart_case',
        },
      },
    })

    pcall(require('telescope').load_extension, 'ui-select')
    pcall(require('telescope').load_extension, 'fzf')

    local builtin = require('telescope.builtin')

    vim.keymap.set('n', '<leader><leader>', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[S]earch [B]uffers' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch [String] in files' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sq', builtin.quickfix, { desc = '[S]earch [Q]uickfix' })

    vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = '[G]it [S]tatus' })
    vim.keymap.set('n', '<leader>gb', function()
      builtin.git_bcommits({
        git_command = {
          'git',
          '--no-pager',
          'log',
          '--pretty=tformat:%h %s | %an | %ad',
          '--abbrev-commit',
          '--date=format-local:%Y-%m-%d %I:%M %p',
          '--follow',
        },
      })
    end, { desc = '[G]it [B]uffer Commits' })
    vim.keymap.set('n', '<leader>gc', function()
      builtin.git_commits({
        git_command = {
          'git',
          '--no-pager',
          'log',
          '--pretty=tformat:%h %s | %an | %ad',
          '--abbrev-commit',
          '--date=format-local:%Y-%m-%d %I:%M %p',
          '--',
          '.',
        },
      })
    end, { desc = '[G]it [C]ommits' })
    vim.keymap.set('n', '<leader>gh', builtin.git_stash, { desc = '[G]it stas[H]' })
    vim.keymap.set(
      'n',
      '<leader>sh',
      ':Telescope find_files hidden=true no_ignore=true <CR>',
      { desc = '[S]earch [H]idden files' }
    )
    vim.keymap.set('n', '<leader>/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })
  end,
}
