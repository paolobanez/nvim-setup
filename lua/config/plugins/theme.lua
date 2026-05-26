return {
  "ribru17/bamboo.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "vulgaris",
    transparent = false,
    dim_inactive = false,
    term_colors = true,
    ending_tildes = false,
    code_style = {
      comments = { italic = false },
      conditionals = { italic = false },
      keywords = {},
      functions = {},
      namespaces = { italic = false },
      parameters = { italic = false },
      strings = {},
      variables = {},
    },
  },
  config = function(_, opts)
    require("bamboo").setup(opts)
    require("bamboo").load()
  end,
}
