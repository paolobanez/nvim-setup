return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
    { 'nvim-telescope/telescope-dap.nvim', dependencies = { 'nvim-telescope/telescope.nvim' } },
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    dapui.setup()
    require('nvim-dap-virtual-text').setup()
    pcall(require('telescope').load_extension, 'dap')

    dap.listeners.before.attach.dapui_config = function() dapui.open() end
    dap.listeners.before.launch.dapui_config = function() dapui.open() end
    dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
    dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

    -- JavaScript / TypeScript (Next.js)
    local js_debug = vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js'
    for _, adapter in ipairs({ 'pwa-node', 'pwa-chrome', 'node-terminal' }) do
      dap.adapters[adapter] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = { js_debug, '${port}' },
        },
      }
    end

    local app_root = '${workspaceFolder}'

    local js_configs = {
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Next.js: dev server',
        program = app_root .. '/node_modules/next/dist/bin/next',
        args = { 'dev' },
        cwd = app_root,
        killBehavior = 'forceful',
        sourceMaps = true,
        skipFiles = { '<node_internals>/**', '**/node_modules/**' },
        resolveSourceMapLocations = { app_root .. '/**', '!' .. app_root .. '/node_modules/**' },
      },
      {
        type = 'pwa-node',
        request = 'attach',
        name = 'Next.js: attach (9229)',
        port = 9229,
        cwd = app_root,
        continueOnAttach = true,
        sourceMaps = true,
        skipFiles = { '<node_internals>/**', '**/node_modules/**' },
        resolveSourceMapLocations = { app_root .. '/**', '!' .. app_root .. '/node_modules/**' },
      },
      {
        type = 'pwa-chrome',
        request = 'launch',
        name = 'Next.js: Chrome client',
        url = 'http://localhost:3000',
        webRoot = app_root,
        sourceMaps = true,
        sourceMapPathOverrides = {
          ['webpack://_N_E/*'] = app_root .. '/*',
          ['webpack://@?:*/?:*/*'] = app_root .. '/*',
          ['turbopack://[project]/*'] = app_root .. '/*',
        },
      },
    }

    for _, ft in ipairs({ 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }) do
      dap.configurations[ft] = js_configs
    end

    -- .NET
    local netcoredbg = vim.fn.stdpath('data') .. '/mason/packages/netcoredbg/netcoredbg'
    if vim.uv.os_uname().sysname == 'Windows_NT' then
      netcoredbg = netcoredbg .. '.exe'
    end
    dap.adapters.coreclr = {
      type = 'executable',
      command = netcoredbg,
      args = { '--interpreter=vscode' },
    }
    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'Launch .NET',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to DLL: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
        cwd = '${workspaceFolder}',
      },
    }

    -- Keymaps
    vim.keymap.set('n', '<leader>dc', dap.continue,  { desc = 'Debug: Continue' })
    vim.keymap.set('n', '<leader>dj', dap.step_over,  { desc = 'Debug: Step over' })
    vim.keymap.set('n', '<leader>dk', dap.step_into,  { desc = 'Debug: Step into' })
    vim.keymap.set('n', '<leader>dh', dap.step_out,   { desc = 'Debug: Step out' })
    vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle breakpoint' })
    vim.keymap.set('n', '<leader>dB', function()
      dap.set_breakpoint(vim.fn.input('Condition: '))
    end, { desc = 'Debug: Conditional breakpoint' })
    vim.keymap.set('n', '<leader>du', dapui.toggle,      { desc = 'Debug: Toggle UI' })
    vim.keymap.set('n', '<leader>dr', dap.repl.toggle,   { desc = 'Debug: Toggle REPL' })
    vim.keymap.set('n', '<leader>dx', dap.terminate,     { desc = 'Debug: Terminate' })
    vim.keymap.set({ 'n', 'v' }, '<leader>de', dapui.eval, { desc = 'Debug: Eval expression' })
    vim.keymap.set('n', '<leader>dtc', function()
      require('telescope').extensions.dap.configurations({ filetype = vim.bo.filetype })
    end, { desc = 'Debug: Pick config' })
  end,
}
