return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    main = "nvim-treesitter.configs",
    opts = {
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "CursorMoved",
  }
}
