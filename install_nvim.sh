#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║          Neovim Installer · @Juguitos                        ║
# ║   Instala nvim + config optimizada para pentesting           ║
# ╚══════════════════════════════════════════════════════════════╝
# Uso: bash install_nvim.sh

set -euo pipefail

GRN='\033[0;32m'; CYN='\033[0;36m'; YLW='\033[0;33m'; NC='\033[0m'
ok()   { echo -e "${GRN}[+]${NC} $*"; }
info() { echo -e "${CYN}[*]${NC} $*"; }
warn() { echo -e "${YLW}[!]${NC} $*"; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG="$HOME/.config/nvim"

# ─── Instalar neovim (última versión estable) ─────────────────────────────────
install_nvim() {
    if command -v nvim &>/dev/null; then
        local ver
        ver=$(nvim --version | head -1)
        warn "Neovim ya instalado: $ver"
        return
    fi

    info "Descargando Neovim..."
    curl -sLo /tmp/nvim.tar.gz \
        https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo tar -xzf /tmp/nvim.tar.gz -C /opt
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    ok "Neovim instalado: $(nvim --version | head -1)"
}

# ─── Dependencias de los plugins ─────────────────────────────────────────────
install_deps() {
    info "Instalando dependencias..."
    sudo apt install -y \
        nodejs npm \
        python3-pip \
        ripgrep fd-find \
        --no-install-recommends 2>&1 | grep -E "^(Get|Unpacking)" || true

    # bash-language-server (para bashls)
    if ! command -v bash-language-server &>/dev/null; then
        sudo npm install -g bash-language-server
        ok "bash-language-server instalado"
    fi

    # pyright (para python)
    if ! command -v pyright &>/dev/null; then
        sudo npm install -g pyright
        ok "pyright instalado"
    fi

    ok "Dependencias instaladas"
}

# ─── Desplegar config de nvim ─────────────────────────────────────────────────
deploy_config() {
    info "Desplegando config de nvim..."

    # Backup si existe
    if [[ -d "$NVIM_CONFIG" ]]; then
        mv "$NVIM_CONFIG" "${NVIM_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
        warn "Config anterior → ${NVIM_CONFIG}.bak.*"
    fi

    mkdir -p "$NVIM_CONFIG"
    cp -r "$REPO_DIR/nvim/." "$NVIM_CONFIG/"
    ok "Config copiada → $NVIM_CONFIG"
}

# ─── Primera ejecución (instala plugins) ─────────────────────────────────────
first_run() {
    info "Instalando plugins (lazy.nvim)..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    ok "Plugins instalados"
}

main() {
    echo ""
    echo -e "${GRN}══ Neovim Setup · @Juguitos ══${NC}"
    echo ""
    install_nvim
    install_deps
    deploy_config
    first_run
    echo ""
    ok "Neovim listo. Ejecuta: nvim"
    echo ""
    echo -e "${CYN}Atajos principales:${NC}"
    echo "  Space+e       → File explorer"
    echo "  Space+ff      → Buscar archivos"
    echo "  Space+fg      → Buscar texto"
    echo "  Space+t / C-t → Terminal"
    echo "  Space+w/q     → Guardar / Salir"
    echo "  Space+sb      → Insertar bash shebang"
    echo "  Space+sp      → Insertar python shebang"
    echo "  Space+x       → Ejecutar script bash"
    echo "  Space+xp      → Ejecutar script python"
    echo "  gcc           → Comentar línea"
    echo "  jk o jj       → Salir insert mode"
    echo ""
}

main "$@"

