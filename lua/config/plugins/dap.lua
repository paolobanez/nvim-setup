return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')
    local sysname = vim.uv.os_uname().sysname

    dapui.setup()

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    local netcoredbg = vim.fn.stdpath('data') .. '/mason/packages/netcoredbg/netcoredbg'
    if sysname == 'Windows_NT' then
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
        name = 'Launch project DLL',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to DLL: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = false,
      },
    }

    dap.adapters['node-terminal'] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = {
        command = 'node',
        args = {
          vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
          '${port}',
        },
      },
    }

    dap.adapters['pwa-node'] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = {
        command = 'node',
        args = {
          vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
          '${port}',
        },
      },
    }

    for _, lang in ipairs({ 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }) do
      dap.configurations[lang] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Next.js (server)',
          runtimeExecutable = 'node',
          runtimeArgs = { '--inspect', '${workspaceFolder}/node_modules/.bin/next', 'dev' },
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          resolveSourceMapLocations = { '${workspaceFolder}/**', '!**/node_modules/**' },
          skipFiles = { '<node_internals>/**', '**/node_modules/**' },
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to Next.js',
          port = 9229,
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          skipFiles = { '<node_internals>/**', '**/node_modules/**' },
        },
      }
    end

    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Continue/Start' })
    vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step over' })
    vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step into' })
    vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step out' })
    vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle breakpoint' })
    vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug: Continue' })
    vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Debug: Toggle UI' })
    vim.keymap.set('n', '<leader>dr', dap.repl.toggle, { desc = 'Debug: Toggle REPL' })
    vim.keymap.set('n', '<leader>dx', dap.terminate, { desc = 'Debug: Terminate' })
  end,
}
