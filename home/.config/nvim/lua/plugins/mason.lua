return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "saghen/blink.cmp",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "gopls",
      },

      handlers = {
        function(servers_name)
          lspconfig = require("lspconfig")
          mason_lspconfig = require("mason-lspconfig")

          -- set keymaps
          local on_attach = function()
            vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
            vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
            vim.keymap.set('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
            vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
            vim.keymap.set('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>')
            vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
            vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')
            vim.keymap.set('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
          end

          lspconfig[servers_name].setup({
            capabilities = capabilities,
          })
          local default_opts = {
            on_attach = on_attach
          }

          local installed_servers = mason_lspconfig.get_installed_servers()
          for i = 1, #installed_servers do
              local server_name = installed_servers[i]
              lspconfig[server_name].setup(default_opts)
          end
        end,
      },
    },
  },
}
