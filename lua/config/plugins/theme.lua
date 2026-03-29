return {
  "yorickpeterse/vim-paper",
  name = "paper",
  config = function()
    vim.cmd("colorscheme paper")

    local custom_bg = "#E8E4E1"
    vim.cmd(("highlight Normal guibg=%s"):format(custom_bg))
    vim.cmd(("highlight NormalNC guibg=%s"):format(custom_bg))
    vim.cmd(("highlight SignColumn guibg=%s"):format(custom_bg))
    vim.cmd(("highlight EndOfBuffer guibg=%s"):format(custom_bg))
  end,
}
