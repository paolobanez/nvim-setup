return {
  "Mofiqul/vscode.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = false,
    italic_comments = false,
  },
  config = function(_, opts)
    require("vscode").setup(opts)
    vim.cmd("colorscheme vscode")
  end,
}
