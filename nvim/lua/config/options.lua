-- ─── Opciones generales ──────────────────────────────────────────────────────
local opt = vim.opt

-- UI
opt.number         = true          -- números de línea
opt.relativenumber = true          -- números relativos (útil para navegar)
opt.cursorline     = true          -- resalta línea actual
opt.signcolumn     = "yes"         -- columna de signos (git, errores)
opt.scrolloff      = 8             -- mantiene 8 líneas visibles al scroll
opt.termguicolors  = true          -- colores 24bit
opt.showmode       = false         -- no muestra -- INSERT -- (lo hace la statusline)
opt.cmdheight      = 1
opt.pumheight      = 10            -- max items en popup de autocompletado

-- Indentación
opt.tabstop        = 4
opt.shiftwidth     = 4
opt.expandtab      = true          -- espacios en vez de tabs
opt.smartindent    = true
opt.autoindent     = true

-- Búsqueda
opt.hlsearch       = true
opt.incsearch      = true
opt.ignorecase     = true
opt.smartcase      = true          -- case-sensitive si hay mayúsculas

-- Splits
opt.splitright     = true          -- split vertical → derecha
opt.splitbelow     = true          -- split horizontal → abajo

-- Archivos
opt.undofile       = true          -- deshacer persistente entre sesiones
opt.swapfile       = false
opt.backup         = false
opt.updatetime     = 250

-- Clipboard
opt.clipboard      = "unnamedplus" -- comparte portapapeles con el sistema

-- Encoding
opt.encoding       = "utf-8"
opt.fileencoding   = "utf-8"

-- Wrap
opt.wrap           = false         -- no wrappear líneas largas
opt.linebreak      = true

-- Mouse
opt.mouse          = "a"
