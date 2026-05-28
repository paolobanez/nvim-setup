return {
  "the-coding-doggo/batman.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    theme = "classic",
    use_persistence = false,
  },
  config = function(_, opts)
    require("batman").setup(opts)
    require("batman").load()
  end,
}
