-- ─── Lazy.nvim bootstrap ─────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ─── Plugins ─────────────────────────────────────────────────────────────────
require("lazy").setup({

    -- ── Colorscheme (Tokyo Night - compatible con paleta HTB) ────────────────
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "night",
                transparent = true,        -- fondo transparente (kitty opacity)
                terminal_colors = true,
                styles = {
                    comments  = { italic = true },
                    keywords  = { italic = true },
                    functions = {},
                    variables = {},
                    sidebars  = "dark",
                    floats    = "dark",
                },
                on_colors = function(colors)
                    -- Ajusta verde a paleta HTB
                    colors.green   = "#63CC00"
                    colors.green1  = "#00CC69"
                    colors.teal    = "#00CC69"
                end,
            })
            vim.cmd("colorscheme tokyonight-night")
        end,
    },

    -- ── Statusline ───────────────────────────────────────────────────────────
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "tokyonight",
                    globalstatus = true,
                    component_separators = { left = "", right = "" },
                    section_separators   = { left = "", right = "" },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    -- ── File explorer ─────────────────────────────────────────────────────────
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            vim.g.loaded_netrw       = 1
            vim.g.loaded_netrwPlugin = 1
            require("nvim-tree").setup({
                view = { width = 30 },
                renderer = {
                    group_empty = true,
                    icons = { show = { git = true, file = true, folder = true } },
                },
                filters = { dotfiles = false },
            })
        end,
    },

    -- ── Telescope (fuzzy finder) ──────────────────────────────────────────────
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    prompt_prefix = "  ",
                    selection_caret = " ",
                    path_display = { "smart" },
                },
            })
        end,
    },

    -- ── Treesitter (syntax avanzado) ──────────────────────────────────────────
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "bash", "python", "lua", "vim",
                    "json", "yaml", "markdown",
                    "html", "css", "javascript",
                },
                highlight    = { enable = true },
                indent       = { enable = true },
                auto_install = true,
            })
        end,
    },

    -- ── Autocompletado ───────────────────────────────────────────────────────
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local cmp     = require("cmp")
            local luasnip = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"]     = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"]     = cmp.mapping.abort(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"]     = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                        else fallback() end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                        else fallback() end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },

    -- ── LSP ──────────────────────────────────────────────────────────────────
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup({
                ui = {
                    border = "rounded",
                    icons  = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
                },
            })
            require("mason-lspconfig").setup({
                ensure_installed = { "bashls", "pyright", "lua_ls" },
                automatic_installation = true,
            })

            local lspconfig = require("lspconfig")
            local caps      = require("cmp_nvim_lsp").default_capabilities()

            -- Bash LSP (útil para scripts de pentesting)
            lspconfig.bashls.setup({ capabilities = caps })

            -- Python LSP (para scripts de explotación)
            lspconfig.pyright.setup({ capabilities = caps })

            -- Lua LSP
            lspconfig.lua_ls.setup({
                capabilities = caps,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace   = { checkThirdParty = false },
                    },
                },
            })

            -- Keymaps LSP (solo cuando hay servidor activo)
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(ev)
                    local b = { buffer = ev.buf, noremap = true, silent = true }
                    vim.keymap.set("n", "gd",         vim.lsp.buf.definition,      b)
                    vim.keymap.set("n", "K",          vim.lsp.buf.hover,           b)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,          b)
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,     b)
                    vim.keymap.set("n", "gr",         vim.lsp.buf.references,      b)
                    vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,    b)
                    vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,    b)
                end,
            })
        end,
    },

    -- ── Terminal integrado ───────────────────────────────────────────────────
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup({
                size          = 15,
                open_mapping  = [[<C-t>]],
                direction     = "horizontal",
                close_on_exit = true,
                shell         = "zsh",
            })
        end,
    },

    -- ── Git signs ────────────────────────────────────────────────────────────
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add          = { text = "│" },
                    change       = { text = "│" },
                    delete       = { text = "󰍵" },
                    topdelete    = { text = "‾" },
                    changedelete = { text = "~" },
                },
            })
        end,
    },

    -- ── Autopairs ────────────────────────────────────────────────────────────
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },

    -- ── Comentarios ──────────────────────────────────────────────────────────
    {
        "numToStr/Comment.nvim",
        config = true,  -- gcc para comentar línea, gc en visual
    },

    -- ── Indentación visual ───────────────────────────────────────────────────
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            require("ibl").setup({
                indent = { char = "│" },
                scope  = { enabled = true },
            })
        end,
    },

    -- ── Which-key (ayuda de atajos) ───────────────────────────────────────────
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup({})
            require("which-key").add({
                { "<leader>f",  group = "Telescope" },
                { "<leader>b",  group = "Buffers" },
                { "<leader>s",  group = "Shebang / Script" },
                { "<leader>x",  group = "Ejecutar" },
            })
        end,
    },

    -- ── Dashboard (pantalla de inicio) ───────────────────────────────────────
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha   = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                "                                                    ",
                "  ██╗  ██╗████████╗██████╗     ███████╗███████╗    ",
                "  ██║  ██║╚══██╔══╝██╔══██╗    ██╔════╝██╔════╝    ",
                "  ███████║   ██║   ██████╔╝    ███████╗█████╗      ",
                "  ██╔══██║   ██║   ██╔══██╗    ╚════██║██╔══╝      ",
                "  ██║  ██║   ██║   ██████╔╝    ███████║███████╗    ",
                "  ╚═╝  ╚═╝   ╚═╝   ╚═════╝     ╚══════╝╚══════╝    ",
                "                   @Juguitos                        ",
                "                                                    ",
            }

            dashboard.section.buttons.val = {
                dashboard.button("f", "  Buscar archivo",     ":Telescope find_files<CR>"),
                dashboard.button("r", "  Archivos recientes", ":Telescope oldfiles<CR>"),
                dashboard.button("g", "  Buscar texto",       ":Telescope live_grep<CR>"),
                dashboard.button("e", "  File explorer",      ":NvimTreeToggle<CR>"),
                dashboard.button("q", "  Salir",              ":qa<CR>"),
            }

            alpha.setup(dashboard.opts)
        end,
    },

    -- ── Notificaciones bonitas ────────────────────────────────────────────────
    {
        "rcarriga/nvim-notify",
        config = function()
            vim.notify = require("notify")
            require("notify").setup({
                background_colour = "#0D0D0D",
                stages = "fade_in_slide_out",
                timeout = 3000,
            })
        end,
    },

}, {
    -- Opciones de lazy.nvim
    ui = {
        border = "rounded",
    },
    checker = {
        enabled = true,   -- avisa de actualizaciones
        notify  = false,
    },
})
