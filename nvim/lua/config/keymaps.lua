-- ─── Keymaps ─────────────────────────────────────────────────────────────────
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ─── Normal mode ─────────────────────────────────────────────────────────────

-- Guardar / Salir
map("n", "<leader>w", ":w<CR>",  opts)
map("n", "<leader>q", ":q<CR>",  opts)
map("n", "<leader>Q", ":qa!<CR>", opts)

-- Navegar ventanas con Ctrl+hjkl
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Redimensionar splits
map("n", "<C-Up>",    ":resize +2<CR>",          opts)
map("n", "<C-Down>",  ":resize -2<CR>",           opts)
map("n", "<C-Left>",  ":vertical resize -2<CR>",  opts)
map("n", "<C-Right>", ":vertical resize +2<CR>",  opts)

-- Buffers
map("n", "<S-l>", ":bnext<CR>",     opts)
map("n", "<S-h>", ":bprevious<CR>", opts)
map("n", "<leader>bd", ":bd<CR>",   opts)

-- Limpiar búsqueda resaltada
map("n", "<Esc>", ":nohl<CR>", opts)

-- Mover líneas arriba/abajo (Alt+j/k)
map("n", "<A-j>", ":m .+1<CR>==",     opts)
map("n", "<A-k>", ":m .-2<CR>==",     opts)

-- Centrar al navegar
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)
map("n", "n",     "nzzzv",   opts)
map("n", "N",     "Nzzzv",   opts)

-- File explorer
map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Telescope
map("n", "<leader>ff", ":Telescope find_files<CR>",  opts)
map("n", "<leader>fg", ":Telescope live_grep<CR>",   opts)
map("n", "<leader>fb", ":Telescope buffers<CR>",     opts)
map("n", "<leader>fh", ":Telescope help_tags<CR>",   opts)
map("n", "<leader>fr", ":Telescope oldfiles<CR>",    opts)

-- Terminal integrado (toggle)
map("n", "<leader>t", ":ToggleTerm<CR>", opts)
map("n", "<C-t>",     ":ToggleTerm<CR>", opts)

-- ─── Insert mode ─────────────────────────────────────────────────────────────
map("i", "jk", "<Esc>", opts)   -- salir de insert mode rápido
map("i", "jj", "<Esc>", opts)

-- ─── Visual mode ─────────────────────────────────────────────────────────────
-- Mover bloque seleccionado
map("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
map("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Mantener selección al indentar
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- ─── Hacking shortcuts ───────────────────────────────────────────────────────
-- Insertar bash shebang
map("n", "<leader>sb", "ggO#!/usr/bin/env bash<CR># ─── <ESC>A", opts)
-- Insertar python shebang
map("n", "<leader>sp", "ggO#!/usr/bin/env python3<CR><ESC>", opts)
-- Ejecutar script actual en terminal
map("n", "<leader>x", ":w<CR>:TermExec cmd='bash %'<CR>", opts)
map("n", "<leader>xp", ":w<CR>:TermExec cmd='python3 %'<CR>", opts)
