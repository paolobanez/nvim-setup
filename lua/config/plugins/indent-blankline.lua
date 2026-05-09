return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = {
    indent = { char = "│" },
    scope = { enabled = true, show_start = false, show_end = false, highlight = "IblScopeActive" },
  },
  config = function(_, opts)
    vim.api.nvim_set_hl(0, "IblScopeActive", { fg = "#7aa2f7" })
    require("ibl").setup(opts)
  end,
}
