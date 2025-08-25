-- Language definitions
local languages = {
    { ts = "lua",        lsp = "lua_ls",              fmt = "luaformatter",       linter = "luacheck" },

    { ts = "python",     lsp = "pyright",             fmt = { "black", "isort" }, linter = "flake8" },
    { ts = "bash",       lsp = "bashls",              fmt = "shfmt",              linter = "shellcheck" },
    { ts = "fish",       lsp = "fish_lsp" },

    { ts = "html",       lsp = "html",                fmt = "prettier" },
    { ts = "css",        lsp = "cssls",               fmt = "prettier" },
    { ts = "scss",       lsp = "cssls",               fmt = "prettier" },
    { ts = "javascript", lsp = "eslint",              fmt = "prettier",           linter = "eslint_d" },
    { ts = "typescript", lsp = { "eslint", "ts_ls" }, fmt = "prettier",           linter = "eslint_d" },

    { ts = "asm",        lsp = "asm_lsp" },
    { ts = "c",          lsp = "clangd",              fmt = "clang-format" },
    { ts = "cpp",        lsp = "clangd",              fmt = "clang-format" },
    { ts = "rust",       lsp = "rust_analyzer", }, -- rustfmt needs to be installed via cargo/rustup
    { ts = "zig",        lsp = "zls", },

    { ts = "go",         lsp = "gopls",               fmt = "goimports" },

    { ts = "glsl",       lsp = "glsl_analyzer" },
    { ts = "sql",        lsp = "sqls",                fmt = "sql-formatter" },

    { ts = "json",       lsp = "jsonls",              fmt = "prettier" },
    { ts = "jsonc",      lsp = "jsonls",              fmt = "prettier" },
    { ts = "toml",       lsp = "taplo",               fmt = "taplo" },
    { ts = "yaml",       lsp = "yamlls",              fmt = "yamlfmt",            linter = "yamllint" },
    { ts = "xml",        lsp = "lemminx",             fmt = "xmlformatter" },

    -- { ts = "dockerfile", lsp = "dockerls",            linter = "hadolint" },
    { ts = "terraform",  lsp = "terraformls",         fmt = "terraform",          linter = "tflint" },
    { ts = "yaml",       lsp = "ansiblels" },
    -- { ts = "nix",        lsp = "nil_ls",              fmt = "nixfmt" },

    { ts = "markdown",   lsp = "marksman",            fmt = "prettier",           linter = "markdownlint" },
    -- { ts = "tex",        lsp = "texlab",              fmt = "latexindent" },
}

-- Custom LSP configuration
local lsp_configs = {
    rust_analyzer = {
        settings = {
            ['rust-analyzer'] = {
                cargo = {
                    -- features = "all",
                },
                checkOnSave = {
                    command = "clippy",
                },
                diagnostics = {
                    enable = true,
                },
            },
        },
    },
    gopls = {
        settings = {
            gopls = {
                completeUnimported = true,
                usePlaceholders = true,
                analyses = {
                    shadow = true,
                    unusedparams = true,
                },
            },
        },
    },
}

local languages_treesitter = {}
local languages_mason = {}

local function add_to_table(target, items)
    if not items then return end
    if type(items) == "table" then
        for _, item in ipairs(items) do
            table.insert(target, item)
        end
    else
        table.insert(target, items)
    end
end
for _, lang in ipairs(languages) do
    add_to_table(languages_treesitter, lang.ts)
    add_to_table(languages_mason, lang.lsp)
    add_to_table(languages_mason, lang.fmt)
    add_to_table(languages_mason, lang.linter)
end

return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = languages_treesitter,
                auto_install = true,
                highlight = { enable = true, },
                indent = { enable = true, },
                -- incremental_selection = { enable = false },
                -- textobjects = { enable = true },
            })

            -- Update all installed treesitter languages
            -- vim.cmd(":TSUpdate")
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            -- Custom signs:
            -- local signs = { Error = "", Warn = "", Hint = "", Info = "" }
            -- for type, icon in pairs(signs) do
            --     local hl = "DiagnosticSign" .. type
            --     vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
            -- end

            -- Inline diagnostics:
            -- vim.diagnostic.config({
            --     virtual_text = { prefix = "●", source = "if_many", spacing = 2 },
            --     signs = true,
            --     underline = true,
            --     update_in_insert = false,
            --     severity_sort = true,
            --     float = { source = "if_many", header = "", prefix = "" },
            -- })
        end,
    },
    {
        "mason-org/mason.nvim",
        opts = {},
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("mason-lspconfig").setup({
                handlers = {
                    function(server_name)
                        local config = lsp_configs[server_name] or {}
                        require("lspconfig")[server_name].setup(config)
                    end,
                }
            })
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            "mason-org/mason.nvim",
        },
        config = function()
            -- Install all mason tools
            require("mason-tool-installer").setup {
                ensure_installed = languages_mason,
                auto_update = true,
            }
        end,
    },
}
