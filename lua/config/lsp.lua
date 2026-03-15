local M = {}

M.servers = {
  'cssls',
  'eslint',
  'html',
  'jsonls',
  'lua_ls',
  'vtsls',
  'prismals',
  'tailwindcss',
}

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

local function set_keymaps()
  local group = vim.api.nvim_create_augroup('config-lsp-keymaps', { clear = true })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(event)
      local map = function(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { buffer = event.buf, silent = true, desc = desc })
      end

      map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
      map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
      map('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
      map('K', vim.lsp.buf.hover, 'Hover docs')
      map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame symbol')
      map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    end,
  })

  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { silent = true, desc = 'Previous diagnostic' })
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { silent = true, desc = 'Next diagnostic' })
end

function M.setup()
  local capabilities = require('blink.cmp').get_lsp_capabilities()

  set_keymaps()

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
