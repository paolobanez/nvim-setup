return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    current_line_blame = false,
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
      end

      map('n', ']h', gs.next_hunk, 'Next hunk')
      map('n', '[h', gs.prev_hunk, 'Previous hunk')
      map('n', '<leader>hs', gs.stage_hunk, '[H]unk [S]tage')
      map('n', '<leader>hr', gs.reset_hunk, '[H]unk [R]eset')
      map('n', '<leader>hS', gs.stage_buffer, '[H]unk [S]tage buffer')
      map('n', '<leader>hu', gs.undo_stage_hunk, '[H]unk [U]ndo stage')
      map('n', '<leader>hR', gs.reset_buffer, '[H]unk [R]eset buffer')
      map('n', '<leader>hp', gs.preview_hunk, '[H]unk [P]review')
      map('n', '<leader>hb', function()
        gs.blame_line({ full = true })
      end, '[H]unk [B]lame')
      map('n', '<leader>tb', gs.toggle_current_line_blame, '[T]oggle line [B]lame')
      map('n', '<leader>hd', gs.diffthis, '[H]unk [D]iff')
      map('n', '<leader>hD', function()
        gs.diffthis('~')
      end, '[H]unk [D]iff ~')
    end,
  },
}
