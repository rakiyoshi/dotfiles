return {
  {
    'saghen/blink.cmp',
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    event = {"InsertEnter", "CmdLineEnter"},
    version = "*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "default" },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },

      completion = { documentation = { auto_show = true } },

      sources = {
        default = { "snippets", "lsp", "path", "buffer" }
      },

      fuzzy = {
        prebuilt_binaries = {
          force_version = "v1.0.0"
        },
        implementation = "prefer_rust_with_warning",
      },
    },
    opts_extend = { "sources.default" },
  },
}
