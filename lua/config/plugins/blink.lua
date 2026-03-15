return {
  'saghen/blink.cmp',

  -- use a release tag to download pre-built binaries
  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'enter',
      ['<Tab>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      ['<C-s>'] = {
        function(cmp)
          cmp.show({ providers = { 'snippets' } })
        end,
      },
    },
    appearance = {
      nerd_font_variant = 'normal',
    },
    completion = { documentation = { auto_show = false } },
    sources = {
      default = { 'lsp', 'snippets', 'path', 'buffer' },
      providers = {
        snippets = {
          should_show_items = function(ctx)
            return ctx.trigger.initial_kind ~= 'trigger_character'
          end,
          opts = {
            search_paths = { vim.fn.stdpath('config') .. '/snippets' },
            global_snippets = { 'all' },
          },
        },
      },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
  opts_extend = { 'sources.default' },
}
