#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                    AutoBspwm · @Juguitos                                    ║
# ║              BSPWM Auto-Installer for Kali Linux                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

RED='\033[0;31m'; GRN='\033[0;32m'; CYN='\033[0;36m'
PRP='\033[0;35m'; YLW='\033[0;33m'; NC='\033[0m'

ok()   { echo -e "${GRN}[+]${NC} $*"; }
info() { echo -e "${CYN}[*]${NC} $*"; }
warn() { echo -e "${YLW}[!]${NC} $*"; }
err()  { echo -e "${RED}[-]${NC} $*"; }
step() { echo -e "\n${PRP}══>${NC} $*"; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.bspwm_backup/$(date +%Y%m%d_%H%M%S)"
CONFIG="$HOME/.config"
DO_BACKUP=false
DO_NVIM=false

banner() {
    clear
    echo -e "${GRN}"
    cat << 'EOF'

    ██████╗ ██╗  ██╗███████╗     ███████╗███████╗████████╗██╗   ██╗██████╗
    ██╔══██╗╚██╗██╔╝╚════██║     ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
    ██████╔╝ ╚███╔╝     ██╔╝     ███████╗█████╗     ██║   ██║   ██║██████╔╝
    ██╔══██╗ ██╔██╗    ██╔╝      ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝
    ██║  ██║██╔╝ ██╗   ██║       ███████║███████╗   ██║   ╚██████╔╝██║
    ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝       ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝

                              @Juguitos · Kali Linux

EOF
    echo -e "${NC}"
}

# ─── Menú de opciones ─────────────────────────────────────────────────────────
ask_options() {
    echo -e "${YLW}╔══════════════════════════════════════════╗${NC}"
    echo -e "${YLW}║         Opciones de instalación          ║${NC}"
    echo -e "${YLW}╚══════════════════════════════════════════╝${NC}"
    echo ""

    read -rp "$(echo -e "${CYN}[?]${NC} ¿Hacer backup de configs actuales? [s/N] ")" resp
    [[ "$resp" =~ ^[sS]$ ]] && DO_BACKUP=true && ok "Backup activado" || warn "Sin backup"

    echo ""
    read -rp "$(echo -e "${CYN}[?]${NC} ¿Instalar Neovim con config para pentesting? [s/N] ")" resp
    [[ "$resp" =~ ^[sS]$ ]] && DO_NVIM=true && ok "Neovim incluido" || warn "Neovim omitido"

    echo ""
    echo -e "${YLW}Resumen:${NC}"
    $DO_BACKUP && echo -e "  Backup  → ${GRN}Sí${NC}" || echo -e "  Backup  → ${RED}No${NC}"
    $DO_NVIM  && echo -e "  Neovim  → ${GRN}Sí${NC}" || echo -e "  Neovim  → ${RED}No${NC}"
    echo ""
    read -rp "$(echo -e "${CYN}[?]${NC} ¿Continuar? [s/N] ")" confirm
    [[ "$confirm" =~ ^[sS]$ ]] || { warn "Abortado."; exit 0; }
}

check_root() {
    [[ "$EUID" -eq 0 ]] && err "No ejecutes como root." && exit 1
}

# ─── Backup opcional ──────────────────────────────────────────────────────────
backup() {
    $DO_BACKUP || return
    step "Haciendo backup..."
    mkdir -p "$BACKUP_DIR"
    for item in bspwm sxhkd kitty polybar rofi picom dunst; do
        [[ -d "$CONFIG/$item" ]] && cp -r "$CONFIG/$item" "$BACKUP_DIR/" 2>/dev/null && ok "Backup: $item"
    done
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.bak" 2>/dev/null && ok "Backup: .zshrc"
    ok "Backup guardado en: $BACKUP_DIR"
}

# ─── Paquetes ─────────────────────────────────────────────────────────────────
install_packages() {
    step "Instalando paquetes..."
    sudo apt update -qq 2>/dev/null

    local pkgs=(
        bspwm sxhkd polybar rofi kitty
        zsh feh picom dunst libnotify-bin
        lxappearance papirus-icon-theme fonts-font-awesome
        thunar xclip xdotool wmctrl
        flameshot btop htop neofetch
        bat fd-find ripgrep fzf
        git curl wget unzip python3-pip
        i3lock-fancy pamixer playerctl
        zsh-autosuggestions zsh-syntax-highlighting
        # Portapapeles compartido VMware
        open-vm-tools open-vm-tools-desktop fastfetch
    )

    for pkg in "${pkgs[@]}"; do
        sudo apt install -y "$pkg" &>/dev/null && ok "$pkg" || warn "Fallo: $pkg"
    done

    # fastfetch (si no está en repos, instalar desde .deb)
    if ! command -v fastfetch &>/dev/null; then
        FASTFETCH_URL=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
            | grep "browser_download_url" | grep "linux-amd64.deb" \
            | cut -d'"' -f4 | head -1)
        if [[ -n "$FASTFETCH_URL" ]]; then
            curl -sL "$FASTFETCH_URL" -o /tmp/fastfetch.deb
            sudo dpkg -i /tmp/fastfetch.deb &>/dev/null && ok "fastfetch instalado"
        fi
    fi

    # eza
    if ! command -v eza &>/dev/null; then
        EZA_URL=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest \
            | grep "browser_download_url" | grep "x86_64-unknown-linux-gnu.tar.gz" \
            | cut -d'"' -f4 | head -1)
        if [[ -n "$EZA_URL" ]]; then
            curl -sL "$EZA_URL" -o /tmp/eza.tar.gz
            tar -xzf /tmp/eza.tar.gz -C /tmp 2>/dev/null
            sudo mv /tmp/eza /usr/local/bin/eza 2>/dev/null && ok "eza instalado"
        fi
    fi

    mkdir -p "$HOME/.local/bin"
    command -v batcat &>/dev/null && ! command -v bat &>/dev/null && \
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat" && ok "bat enlazado"
    command -v fdfind &>/dev/null && ! command -v fd &>/dev/null && \
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd" && ok "fd enlazado"

    ok "Paquetes listos"
}

# ─── Fuentes ──────────────────────────────────────────────────────────────────
install_fonts() {
    step "Instalando fuentes..."
    local FONTS_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONTS_DIR"

    [[ -d "$REPO_DIR/fonts/HNF" ]]    && cp -r "$REPO_DIR/fonts/HNF/."    "$FONTS_DIR/" && ok "HNF copiadas"
    [[ -d "$REPO_DIR/Fonts2/fonts" ]] && cp -r "$REPO_DIR/Fonts2/fonts/." "$FONTS_DIR/" && ok "Fonts2 copiadas"

    if ! fc-list | grep -qi "JetBrainsMono"; then
        info "Descargando JetBrains Mono Nerd Font..."
        curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" \
            -o /tmp/JetBrainsMono.tar.xz
        tar -xf /tmp/JetBrainsMono.tar.xz -C "$FONTS_DIR" 2>/dev/null
        ok "JetBrains Mono instalada"
    else
        warn "JetBrains Mono ya existe"
    fi

    fc-cache -fv &>/dev/null
    ok "Fuentes listas"
}

# ─── Configs ──────────────────────────────────────────────────────────────────
deploy_configs() {
    step "Copiando configuraciones del tema rx7..."
    local T="$REPO_DIR/Themes/rx7"

    mkdir -p \
        "$CONFIG/bspwm/scripts" \
        "$CONFIG/sxhkd" \
        "$CONFIG/kitty" \
        "$CONFIG/polybar/scripts" \
        "$CONFIG/rofi" \
        "$CONFIG/picom" \
        "$CONFIG/dunst" \
        "$HOME/.config/Wallpaper"

    cp "$T/bspwm/bspwmrc"              "$CONFIG/bspwm/bspwmrc"
    cp "$T/bspwm/scripts/bspwm_resize" "$CONFIG/bspwm/scripts/bspwm_resize"
    cp "$T/sxhkd/sxhkdrc"             "$CONFIG/sxhkd/sxhkdrc"
    cp "$T/kitty/kitty.conf"           "$CONFIG/kitty/kitty.conf"
    cp "$T/polybar/config.ini"         "$CONFIG/polybar/config.ini"
    cp "$T/polybar/launch.sh"          "$CONFIG/polybar/launch.sh"
    cp "$T/polybar/scripts/vpn.sh"     "$CONFIG/polybar/scripts/vpn.sh"
    cp "$T/polybar/scripts/target.sh"  "$CONFIG/polybar/scripts/target.sh"
    cp "$T/rofi/launcher.rasi"         "$CONFIG/rofi/launcher.rasi"
    cp "$T/picom/picom.conf"           "$CONFIG/picom/picom.conf"
    cp "$T/dunst/dunstrc"              "$CONFIG/dunst/dunstrc"

    [[ -f "$REPO_DIR/Wallpaper/rx7.jpg" ]] && \
        cp "$REPO_DIR/Wallpaper/rx7.jpg" "$HOME/.config/Wallpaper/rx7.jpg" && ok "Wallpaper copiado"

    chmod +x "$CONFIG/bspwm/bspwmrc"
    chmod +x "$CONFIG/bspwm/scripts/bspwm_resize"
    chmod +x "$CONFIG/polybar/launch.sh"
    chmod +x "$CONFIG/polybar/scripts/vpn.sh"
    chmod +x "$CONFIG/polybar/scripts/target.sh"
    touch "$CONFIG/polybar/scripts/target"

    # Fastfetch config
    mkdir -p "$HOME/.config/fastfetch"
    cp "$REPO_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    cp "$REPO_DIR/fastfetch/rx7.txt"      "$HOME/.config/fastfetch/rx7.txt"
    # Logo personalizado
    [[ -f "$REPO_DIR/logo.txt" ]] && cp "$REPO_DIR/logo.txt" "$HOME/.config/fastfetch/logo.txt" && ok "Logo fastfetch copiado"
    ok "Fastfetch config copiada"

    ok "Configs copiadas"
}

# ─── Fix polybar: detecta interfaz de red real ────────────────────────────────
fix_polybar() {
    step "Ajustando polybar..."
    local IFACE
    IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -1)
    ok "Interfaz detectada: $IFACE"
    sed -i "s/interface-type   = wireless/interface = $IFACE/" "$CONFIG/polybar/config.ini"
    sed -i "s/interface-type = wireless/interface = $IFACE/"   "$CONFIG/polybar/config.ini"
    ok "Polybar configurado con interfaz: $IFACE"
}

# ─── Fix portapapeles compartido VMware ───────────────────────────────────────
fix_clipboard() {
    step "Configurando portapapeles compartido con VMware..."

    # Habilitar e iniciar open-vm-tools
    sudo systemctl enable vmtoolsd 2>/dev/null && ok "vmtoolsd habilitado"
    sudo systemctl start  vmtoolsd 2>/dev/null && ok "vmtoolsd iniciado"

    # Habilitar vmware-user para portapapeles y drag&drop
    sudo systemctl enable open-vm-tools 2>/dev/null
    sudo systemctl start  open-vm-tools 2>/dev/null

    # Agregar vmware-user-suid-wrapper al autostart del bspwmrc
    # para que arranque con la sesión gráfica
    local BSPWMRC="$CONFIG/bspwm/bspwmrc"
    if ! grep -q "vmware-user" "$BSPWMRC" 2>/dev/null; then
        # Inserta antes de la última línea
        sed -i '/^# Autostart/a # Portapapeles compartido VMware\n[ -x "$(command -v vmware-user-suid-wrapper)" ] \&\& vmware-user-suid-wrapper \&\n[ -x "$(command -v vmware-user)" ] \&\& vmware-user \&' "$BSPWMRC"
        ok "vmware-user agregado al autostart de bspwm"
    else
        warn "vmware-user ya estaba en bspwmrc"
    fi

    # xclip es necesario para los scripts de target/vpn
    command -v xclip &>/dev/null && ok "xclip disponible" || warn "xclip no encontrado"

    ok "Portapapeles configurado"
    echo ""
    warn "NOTA: En VMware asegúrate de tener habilitado:"
    warn "  VM → Settings → Options → Guest Isolation"
    warn "  ✅ Enable copy and paste"
    warn "  ✅ Enable drag and drop"
}

# ─── Neovim opcional ──────────────────────────────────────────────────────────
install_nvim() {
    $DO_NVIM || return
    step "Instalando Neovim..."

    if ! command -v nvim &>/dev/null; then
        curl -sLo /tmp/nvim.tar.gz \
            https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        sudo tar -xzf /tmp/nvim.tar.gz -C /opt
        sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
        ok "Neovim instalado: $(nvim --version | head -1)"
    else
        warn "Neovim ya instalado"
    fi

    sudo apt install -y nodejs npm &>/dev/null
    sudo npm install -g bash-language-server pyright &>/dev/null && ok "LSP instalados"

    local NVIM_SRC="$REPO_DIR/nvim"
    local NVIM_DST="$HOME/.config/nvim"

    if [[ -d "$NVIM_SRC" ]]; then
        [[ -d "$NVIM_DST" ]] && mv "$NVIM_DST" "${NVIM_DST}.bak.$(date +%H%M%S)"
        cp -r "$NVIM_SRC" "$NVIM_DST"
        ok "Config nvim copiada"
        info "Instalando plugins..."
        nvim --headless "+Lazy! sync" +qa 2>/dev/null && ok "Plugins instalados" || \
            warn "Abre nvim manualmente para instalar plugins"
    else
        warn "Carpeta nvim/ no encontrada en el repo"
    fi
}

# ─── ZSH (siempre al final) ───────────────────────────────────────────────────
install_zsh() {
    step "Configurando ZSH..."

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        ok "Oh-My-Zsh instalado"
    else
        warn "Oh-My-Zsh ya existe"
    fi

    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    for entry in \
        "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions" \
        "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting" \
        "zsh-history-substring-search|https://github.com/zsh-users/zsh-history-substring-search"
    do
        name="${entry%%|*}"; url="${entry##*|}"
        [[ ! -d "$ZSH_CUSTOM/plugins/$name" ]] && \
            git clone --depth=1 "$url" "$ZSH_CUSTOM/plugins/$name" 2>/dev/null && ok "Plugin: $name" || \
            warn "Plugin ya existe: $name"
    done

    [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]] && \
        git clone --depth=1 https://github.com/romkatv/powerlevel10k \
        "$ZSH_CUSTOM/themes/powerlevel10k" 2>/dev/null && ok "Powerlevel10k" || \
        warn "Powerlevel10k ya existe"

    cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
    ok ".zshrc copiado"

    [[ "$SHELL" != "$(command -v zsh)" ]] && \
        sudo chsh -s "$(command -v zsh)" "$USER" && ok "Shell → ZSH"
}

# ─── Registrar sesión BSPWM ───────────────────────────────────────────────────
register_bspwm() {
    step "Registrando sesión BSPWM..."
    local DK="/usr/share/xsessions/bspwm.desktop"
    [[ ! -f "$DK" ]] && sudo tee "$DK" > /dev/null << 'EOF'
[Desktop Entry]
Name=bspwm
Comment=Binary Space Partitioning Window Manager
Exec=bspwm
Type=Application
EOF
    ok "Sesión BSPWM lista"
}

# ─── Resumen final ────────────────────────────────────────────────────────────
summary() {
    echo ""
    echo -e "${GRN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GRN}║       ✓  Instalación completada · @Juguitos          ║${NC}"
    echo -e "${GRN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YLW}  PRÓXIMOS PASOS:${NC}"
    echo "  1. Cierra sesión completamente"
    echo "  2. En el login selecciona → ${GRN}bspwm${NC}"
    echo "  3. Ejecuta ${CYN}p10k configure${NC} para el prompt"
    echo ""
    echo -e "${CYN}  Portapapeles VMware:${NC}"
    echo "  VM → Settings → Options → Guest Isolation"
    echo "  ✅ Enable copy and paste"
    echo "  ✅ Enable drag and drop"
    echo ""
    echo -e "${CYN}  Si polybar no carga:${NC}"
    echo "  ~/.config/polybar/launch.sh"
    echo "  cat /tmp/polybar.log"
    echo ""
    $DO_NVIM && echo -e "  ${CYN}Neovim:${NC} escribe ${YLW}nvim${NC} o ${YLW}vim${NC}"
    echo ""
    echo -e "${RED}  Reinicia la sesión para aplicar cambios.${NC}"
    echo ""
}

main() {
    banner
    check_root
    ask_options
    backup
    install_packages
    install_fonts
    deploy_configs
    fix_polybar
    fix_clipboard     # ← nuevo
    register_bspwm
    install_nvim
    install_zsh
    summary
}

main "$@"
