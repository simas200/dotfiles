local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

local default_setup = function(server)
  require('lspconfig')[server].setup({
    capabilities = lsp_capabilities,
  })
end

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {"clangd", "csharp_ls", "omnisharp", "cssls", "crystalline", "elixirls", "lua_ls", "pylyzer", "rust_analyzer" },
    handlers = {
        default_setup,
        function (server_name)
            require("lspconfig")[server_name].setup{}
        end,
        ['clangd'] = function()
        end,
        ['csharp_ls'] = function()
        end,
        ['omnisharp'] = function()
        end,
        ['cssls'] = function()
        end,
        ['crystalline'] = function()
        end,
        ['elixirls'] = function()
        end,
        ['pylyzer'] = function()
            --require("pylint").setup{}
        end,
        ['rust_analyzer'] = function()
            require('rust-tools').setup{}
        end,
        ['lua_ls'] = function()
            local lspconfig = require('lspconfig')
            lspconfig.lua_ls.setup {
                settings = {
                    Lua = {
                        runtime = {
                            version = 'LuaJIT'
                        },
                        diagnostics = {
                            globals = {'vim'},
                        },
                        workspace = {
                            library = {
                                vim.env.VIMRUNTIME,
                            }
                        }
                    }
                }
            }
        end
    },
})

local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({
    -- Enter key confirms completion item
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl + space triggers completion menu
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})
