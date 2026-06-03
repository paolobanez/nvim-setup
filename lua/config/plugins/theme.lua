return {
  "datsfilipe/vesper.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    italics = {
      comments = false,
      keywords = false,
      functions = false,
      strings = false,
      variables = false,
    },
  },
  config = function(_, opts)
    require("vesper").setup(opts)
    vim.cmd("colorscheme vesper")
  end,
}
