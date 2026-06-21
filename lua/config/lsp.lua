local M = {}

M.servers = {
  'omnisharp',
  'cssls',
  'eslint',
  'html',
  'jsonls',
  'lua_ls',
  'vtsls',
  'prismals',
  'tailwindcss',
  'emmet_ls',
}

local function dotnet_root(bufnr, on_dir)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local start = vim.fs.dirname(bufname)
  local project_file = vim.fs.find(function(name)
    return name:match('%.sln$') ~= nil or name:match('%.csproj$') ~= nil
  end, { path = start, upward = true, type = 'file' })[1]

  if project_file then
    on_dir(vim.fs.dirname(project_file))
    return
  end

  local git_root = vim.fs.root(bufnr, '.git')
  on_dir(git_root or vim.fn.getcwd())
end

local function tailwind_root(bufnr, on_dir)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local start = vim.fs.dirname(bufname)
  local config_file = vim.fs.find({
    'tailwind.config.js',
    'tailwind.config.cjs',
    'tailwind.config.mjs',
    'tailwind.config.ts',
    'tailwind.config.cts',
    'tailwind.config.mts',
    'postcss.config.js',
    'postcss.config.cjs',
    'postcss.config.mjs',
    'postcss.config.ts',
    'postcss.config.cts',
    'postcss.config.mts',
  }, { path = start, upward = true, type = 'file' })[1]

  if config_file then
    on_dir(vim.fs.dirname(config_file))
  end
end

local function prisma_root(bufnr, on_dir)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local start = vim.fs.dirname(bufname)
  local schema = vim.fs.find({ 'schema.prisma', 'prisma/schema.prisma' }, { path = start, upward = true, type = 'file' })[1]

  if schema then
    local root = vim.fs.dirname(schema)
    if vim.fs.basename(root) == 'prisma' then
      root = vim.fs.dirname(root)
    end
    on_dir(root)
    return
  end

  local root = vim.fs.root(bufnr, { 'package.json', 'pnpm-workspace.yaml', '.git' })
  on_dir(root or vim.fn.getcwd())
end

local function prisma_fmt_path(root_dir)
  local local_bin = vim.fs.find(
    { 'node_modules/.bin/prisma-fmt', 'node_modules/.bin/prisma-fmt.cmd' },
    { path = root_dir, upward = true, type = 'file' }
  )[1]

  if local_bin then
    return local_bin
  end

  return vim.fn.exepath('prisma-fmt')
end

local function set_document_highlight(client, bufnr)
  if not client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
    return
  end

  if vim.b[bufnr].document_highlight_enabled then
    return
  end

  vim.b[bufnr].document_highlight_enabled = true

  local function goto_reference(direction)
    local refs = vim.b[bufnr].lsp_references or {}
    if #refs == 0 then return end
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cur_line, cur_col = cursor[1] - 1, cursor[2]

    -- find which ref the cursor is currently inside (range start <= cursor < range end)
    local cur_idx
    for i, ref in ipairs(refs) do
      local s, e = ref.range.start, ref.range['end']
      local on = (s.line < cur_line or (s.line == cur_line and s.character <= cur_col))
             and (e.line > cur_line or (e.line == cur_line and e.character > cur_col))
      if on then cur_idx = i; break end
    end

    local target_idx
    if cur_idx then
      target_idx = direction == 'next'
        and (cur_idx < #refs and cur_idx + 1 or 1)
        or  (cur_idx > 1    and cur_idx - 1 or #refs)
    else
      if direction == 'next' then
        for i, ref in ipairs(refs) do
          local s = ref.range.start
          if s.line > cur_line or (s.line == cur_line and s.character > cur_col) then
            target_idx = i; break
          end
        end
        target_idx = target_idx or 1
      else
        for i = #refs, 1, -1 do
          local s = refs[i].range.start
          if s.line < cur_line or (s.line == cur_line and s.character < cur_col) then
            target_idx = i; break
          end
        end
        target_idx = target_idx or #refs
      end
    end

    local s = refs[target_idx].range.start
    vim.api.nvim_win_set_cursor(0, { s.line + 1, s.character })
  end

  vim.keymap.set('n', ']]', function() goto_reference('next') end, { buffer = bufnr, desc = 'Next reference' })
  vim.keymap.set('n', '[[', function() goto_reference('prev') end, { buffer = bufnr, desc = 'Prev reference' })

  local group = vim.api.nvim_create_augroup(('config-lsp-document-highlight-%d'):format(bufnr), { clear = true })

  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    group = group,
    buffer = bufnr,
    callback = function()
      local params = vim.lsp.util.make_position_params(0, 'utf-16')
      vim.lsp.buf_request(bufnr, 'textDocument/documentHighlight', params, function(_, result)
        vim.lsp.util.buf_highlight_references(bufnr, result or {}, 'utf-16')
        vim.b[bufnr].lsp_references = result or {}
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'InsertEnter', 'BufLeave' }, {
    group = group,
    buffer = bufnr,
    callback = vim.lsp.buf.clear_references,
  })

  vim.api.nvim_create_autocmd('LspDetach', {
    group = group,
    buffer = bufnr,
    callback = function(event)
      local has_other_highlight_client = false
      for _, attached_client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if attached_client.id ~= event.data.client_id
          and attached_client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          has_other_highlight_client = true
          break
        end
      end

      if has_other_highlight_client then
        return
      end

      vim.lsp.buf.clear_references()
      pcall(vim.api.nvim_del_augroup_by_id, group)
      vim.b[bufnr].document_highlight_enabled = false
    end,
  })
end

local function set_keymaps()
  local group = vim.api.nvim_create_augroup('config-lsp-keymaps', { clear = true })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      local map = function(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { buffer = event.buf, silent = true, desc = desc })
      end

      local builtin = require('telescope.builtin')
      map('gd', function()
        local params = vim.lsp.util.make_position_params(0, 'utf-16')
        local bufname = vim.api.nvim_buf_get_name(event.buf)
        local cursor = vim.api.nvim_win_get_cursor(0)
        vim.lsp.buf_request_all(event.buf, 'textDocument/definition', params, function(results)
          for _, res in pairs(results) do
            if res.result and #res.result > 0 then
              local loc = res.result[1]
              local uri = loc.uri or loc.targetUri
              local range = loc.range or loc.targetSelectionRange
              local same_file = uri == vim.uri_from_fname(bufname)
              local same_pos = same_file and range
                and range.start.line == cursor[1] - 1
                and range.start.character == cursor[2]
              if not same_pos then
                return builtin.lsp_definitions()
              end
            end
          end
          vim.lsp.buf_request_all(event.buf, 'textDocument/implementation', params, function(impl_results)
            for _, res in pairs(impl_results) do
              if res.result and #res.result > 0 then
                local loc = res.result[1]
                local uri = loc.uri or loc.targetUri
                local range = loc.range or loc.targetSelectionRange
                local same_file = uri == vim.uri_from_fname(bufname)
                local same_pos = same_file and range
                  and range.start.line == cursor[1] - 1
                  and range.start.character == cursor[2]
                if not same_pos then
                  return builtin.lsp_implementations()
                end
              end
            end
            builtin.lsp_references()
          end)
        end)
      end, '[G]oto [D]efinition or [I]mplementation')
      map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      map('gr', builtin.lsp_references, '[G]oto [R]eferences')
      map('gi', builtin.lsp_implementations, '[G]oto [I]mplementation')
      map('K', vim.lsp.buf.hover, 'Hover docs')
      vim.keymap.set('n', '<leader>rn', function() return ':IncRename ' .. vim.fn.expand('<cword>') end, { buffer = event.buf, silent = true, expr = true, desc = '[R]e[n]ame symbol' })
      map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

      if client then
        set_document_highlight(client, event.buf)
      end
    end,
  })

  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { silent = true, desc = 'Previous diagnostic' })
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { silent = true, desc = 'Next diagnostic' })
end

function M.setup()
  local capabilities = require('blink.cmp').get_lsp_capabilities()

  set_keymaps()

  -- Some servers emit a VS Code specific command. Ignore it in Neovim.
  vim.lsp.commands['setContext'] = vim.lsp.commands['setContext'] or function() end

  vim.lsp.config('*', {
    capabilities = capabilities,
  })

  vim.lsp.config('lua_ls', {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
      },
    },
  })

  vim.lsp.config('prismals', {
    root_dir = prisma_root,
    settings = {
      prisma = {
        prismaFmtBinPath = '',
      },
    },
    on_new_config = function(new_config, root_dir)
      local fmt = prisma_fmt_path(root_dir)
      new_config.settings.prisma.prismaFmtBinPath = fmt ~= '' and fmt or ''
    end,
  })

  vim.lsp.config('eslint', {
    root_dir = function(bufnr, on_dir)
      local root = vim.fs.root(bufnr, {
        'eslint.config.js',
        'eslint.config.mjs',
        'eslint.config.cjs',
        'eslint.config.ts',
        'eslint.config.mts',
        'eslint.config.cts',
        '.eslintrc',
        '.eslintrc.js',
        '.eslintrc.cjs',
        '.eslintrc.yaml',
        '.eslintrc.yml',
        '.eslintrc.json',
      })
      if root then
        on_dir(root)
      end
    end,
    handlers = {
      ['textDocument/diagnostic'] = function(err, result, ctx, config)
        if err and err.message and err.message:find('Could not find config file') then
          return
        end
        return vim.lsp.diagnostic.on_diagnostic(err, result, ctx, config)
      end,
    },
  })

  vim.lsp.config('emmet_ls', {
    filetypes = { 'html', 'css', 'scss', 'javascriptreact', 'typescriptreact' },
  })

  vim.lsp.config('tailwindcss', {
    root_dir = tailwind_root,
  })

  vim.lsp.config('omnisharp', {
    root_dir = dotnet_root,
    cmd_env = {
      DOTNET_ROLL_FORWARD = 'Major',
    },
    settings = {
      RoslynExtensionsOptions = {
        EnableAnalyzersSupport = true,
        EnableImportCompletion = true,
        AnalyzeOpenDocumentsOnly = true,
      },
      MsBuild = {
        LoadProjectsOnDemand = true,
      },
    },
  })

  local has_mason_lspconfig, mason_lspconfig = pcall(require, 'mason-lspconfig')
  if has_mason_lspconfig then
    mason_lspconfig.setup({
      ensure_installed = M.servers,
      automatic_enable = false,
    })
  end

  for _, server in ipairs(M.servers) do
    vim.lsp.enable(server)
  end
end

return M
