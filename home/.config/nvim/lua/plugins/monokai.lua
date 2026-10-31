return {
  "tanvirtin/monokai.nvim",
  opts = function(_, opts)
    local monokai = require("monokai")
    opts.palette = monokai.classic
  end,
}
