return {
  "Mofiqul/vscode.nvim",
  opts = {
    transparent = false,
    italic_comments = false,
  },
  config = function(_, opts)
    require("vscode").setup(opts)
    vim.cmd("colorscheme vscode")
  end,
}
