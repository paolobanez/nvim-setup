return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  module = 'telescope',

  config = function()
    local entry_display = require('telescope.pickers.entry_display')
    local make_entry = require('telescope.make_entry')

    local git_commit_entry_maker = function(opts)
      local displayer = entry_display.create({
        separator = ' ',
        items = {
          { width = 8 },
          { width = 18 },
          { width = 20 },
          { remaining = true },
        },
      })

      local make_display = function(entry)
        return displayer({
          { entry.value, 'TelescopeResultsIdentifier' },
          { entry.author, 'TelescopeResultsComment' },
          { entry.date, 'TelescopeResultsComment' },
          entry.subject,
        })
      end

      return function(line)
        if line == '' then
          return nil
        end

        local parts = vim.split(line, '\t', { plain = true })
        local sha = parts[1]
        local author = parts[2] or ''
        local date = parts[3] or ''
        local subject = table.concat(vim.list_slice(parts, 4), '\t')

        if subject == '' then
          subject = '<empty commit message>'
        end

        return make_entry.set_default_entry_mt({
          value = sha,
          ordinal = table.concat({ sha, author, date, subject }, ' '),
          author = author,
          date = date,
          subject = subject,
          display = make_display,
          current_file = opts.current_file,
        }, opts)
      end
    end

    require('telescope').setup({
      defaults = {
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            width = { padding = 0 },
            height = { padding = 0 },
            preview_width = 0.5
          }
        },
        sorting_strategy = "ascending",
        preview = { treesitter = true },
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
    local pv = require('telescope.previewers')

    local delta_status = pv.new_termopen_previewer {
      get_command = function(entry, status)
        local git_root = vim.fn.systemlist({ 'git', '-C', vim.fn.fnamemodify(entry.path, ':h'), 'rev-parse', '--show-toplevel' })[1]
        local function git(args)
          local cmd = { 'git', '-C', git_root, '-c', 'core.pager=delta', '-c', 'delta.side-by-side=false' }
          vim.list_extend(cmd, args)
          return cmd
        end
        if entry.status == '??' then
          return git({ 'diff', '--no-index', '/dev/null', entry.path })
        end
        if entry.status:sub(2, 2) == ' ' then
          return git({ 'diff', '--cached', '--', entry.value })
        end
        return git({ 'diff', 'HEAD', '--', entry.value })
      end,
    }

    local delta_commit = pv.new_termopen_previewer {
      get_command = function(entry)
        return { 'git', '-c', 'core.pager=delta', '-c', 'delta.side-by-side=false', 'diff', entry.value .. '^!' }
      end
    }

    vim.keymap.set('n', '<leader><leader>', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[S]earch [B]uffers' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch [String] in files' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sq', builtin.quickfix, { desc = '[S]earch [Q]uickfix' })
    vim.keymap.set('n', '<leader>so', builtin.oldfiles, { desc = '[S]earch [O]ld files' })

    vim.keymap.set('n', '<leader>gs', function()
      builtin.git_status({ previewer = delta_status })
    end, { desc = '[G]it [S]tatus' })
    vim.keymap.set('n', '<leader>gb', function()
      local opts = {
        previewer = delta_commit,
        git_command = {
          'git', '--no-pager', 'log',
          '--pretty=tformat:%h%x09%an%x09%ad%x09%s',
          '--abbrev-commit',
          '--date=format-local:%Y-%m-%d %I:%M %p',
          '--follow',
        },
      }
      opts.entry_maker = git_commit_entry_maker(opts)
      builtin.git_bcommits(opts)
    end, { desc = '[G]it [B]uffer Commits' })
    vim.keymap.set('n', '<leader>gc', function()
      local opts = {
        previewer = delta_commit,
        git_command = {
          'git', '--no-pager', 'log',
          '--pretty=tformat:%h%x09%an%x09%ad%x09%s',
          '--abbrev-commit',
          '--date=format-local:%Y-%m-%d %I:%M %p',
          '--', '.',
        },
      }
      opts.entry_maker = git_commit_entry_maker(opts)
      builtin.git_commits(opts)
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
