#!/usr/ GRN='\033[0;32m'; CYN='\033[0;36m'
PRP='\033[0;35m'; YLW='\033[0;33m'; NC='\033[0m'

ok()   { echo -e "${GRN}[+]${NC} $*"; }
info() { echo -e "${CYN}[*]${NC} $*"; }
warn() { echo -e "${YLW}[!]${NC} $*"; }
err()  { echo -e "${RED}[-]${NC} $*"; }
step() { echo -e "\n${PRP}══>${NC} $*"; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.bspwm_backup/$(date +%Y%m%d_%H%M%S)"
CONFIG="$HOME/.config"

# ─── Banner ──────────────────────────────────────────────────────────────────
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

# ─── Checks ───────────────────────────────────────────────────────────────────
check_root() {
    if [[ "$EUID" -eq 0 ]]; then
        err "No ejecutes como root."
        exit 1
    fi
}

# ─── Backup ───────────────────────────────────────────────────────────────────
backup() {
    step "Haciendo backup..."
    mkdir -p "$BACKUP_DIR"
    for item in bspwm sxhkd kitty polybar rofi picom dunst; do
        [[ -d "$CONFIG/$item" ]] && cp -r "$CONFIG/$item" "$BACKUP_DIR/" 2>/dev/null
    done
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.bak" 2>/dev/null
    ok "Backup en: $BACKUP_DIR"
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
    )

    for pkg in "${pkgs[@]}"; do
        sudo apt install -y "$pkg" 2>/dev/null && ok "$pkg" || warn "No se pudo instalar: $pkg"
    done

    # eza
    if ! command -v eza &>/dev/null; then
        info "Instalando eza..."
        EZA_URL=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest \
            | grep "browser_download_url" | grep "x86_64-unknown-linux-gnu.tar.gz" \
            | cut -d'"' -f4 | head -1)
        if [[ -n "$EZA_URL" ]]; then
            curl -sL "$EZA_URL" -o /tmp/eza.tar.gz
            tar -xzf /tmp/eza.tar.gz -C /tmp 2>/dev/null
            sudo mv /tmp/eza /usr/local/bin/eza 2>/dev/null && ok "eza instalado"
        fi
    fi

    # Symlinks batcat → bat y fdfind → fd
    mkdir -p "$HOME/.local/bin"
    command -v batcat &>/dev/null && ! command -v bat &>/dev/null && \
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat" && ok "bat → batcat enlazado"
    command -v fdfind &>/dev/null && ! command -v fd &>/dev/null && \
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd" && ok "fd → fdfind enlazado"

    ok "Paquetes listos"
}

# ─── Fuentes ──────────────────────────────────────────────────────────────────
install_fonts() {
    step "Instalando fuentes..."
    local FONTS_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONTS_DIR"

    [[ -d "$REPO_DIR/fonts/HNF" ]]   && cp -r "$REPO_DIR/fonts/HNF/."   "$FONTS_DIR/" && ok "HNF copiadas"
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

# ─── Configs (copia archivos del tema) ───────────────────────────────────────
deploy_configs() {
    step "Copiando configuraciones..."
    local THEME_DIR="$REPO_DIR/Themes/rx7"

    mkdir -p \
        "$CONFIG/bspwm/scripts" \
        "$CONFIG/sxhkd" \
        "$CONFIG/kitty" \
        "$CONFIG/polybar/scripts" \
        "$CONFIG/rofi" \
        "$CONFIG/picom" \
        "$CONFIG/dunst" \
        "$HOME/.config/Wallpaper"

    cp "$THEME_DIR/bspwm/bspwmrc"              "$CONFIG/bspwm/bspwmrc"
    cp "$THEME_DIR/bspwm/scripts/bspwm_resize" "$CONFIG/bspwm/scripts/bspwm_resize"
    cp "$THEME_DIR/sxhkd/sxhkdrc"             "$CONFIG/sxhkd/sxhkdrc"
    cp "$THEME_DIR/kitty/kitty.conf"           "$CONFIG/kitty/kitty.conf"
    cp "$THEME_DIR/polybar/config.ini"         "$CONFIG/polybar/config.ini"
    cp "$THEME_DIR/polybar/launch.sh"          "$CONFIG/polybar/launch.sh"
    cp "$THEME_DIR/polybar/scripts/vpn.sh"     "$CONFIG/polybar/scripts/vpn.sh"
    cp "$THEME_DIR/polybar/scripts/target.sh"  "$CONFIG/polybar/scripts/target.sh"
    cp "$THEME_DIR/rofi/launcher.rasi"         "$CONFIG/rofi/launcher.rasi"
    cp "$THEME_DIR/picom/picom.conf"           "$CONFIG/picom/picom.conf"
    cp "$THEME_DIR/dunst/dunstrc"              "$CONFIG/dunst/dunstrc"

    # Wallpaper
    [[ -f "$REPO_DIR/Wallpaper/rx7.jpg" ]] && \
        cp "$REPO_DIR/Wallpaper/rx7.jpg" "$HOME/.config/Wallpaper/rx7.jpg" && ok "Wallpaper copiado"

    # Permisos
    chmod +x "$CONFIG/bspwm/bspwmrc"
    chmod +x "$CONFIG/bspwm/scripts/bspwm_resize"
    chmod +x "$CONFIG/polybar/launch.sh"
    chmod +x "$CONFIG/polybar/scripts/vpn.sh"
    chmod +x "$CONFIG/polybar/scripts/target.sh"

    # Archivo target vacío
    touch "$CONFIG/polybar/scripts/target"

    ok "Configs copiadas"
}

# ─── Oh-My-Zsh (al final para que no interrumpa) ─────────────────────────────
install_zsh() {
    step "Configurando ZSH..."

    # Oh-My-Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        ok "Oh-My-Zsh instalado"
    else
        warn "Oh-My-Zsh ya existe"
    fi

    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Plugins
    for entry in \
        "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions" \
        "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting" \
        "zsh-history-substring-search|https://github.com/zsh-users/zsh-history-substring-search"
    do
        name="${entry%%|*}"; url="${entry##*|}"
        if [[ ! -d "$ZSH_CUSTOM/plugins/$name" ]]; then
            git clone --depth=1 "$url" "$ZSH_CUSTOM/plugins/$name" 2>/dev/null && ok "Plugin: $name"
        else
            warn "Plugin ya existe: $name"
        fi
    done

    # Powerlevel10k
    if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k \
            "$ZSH_CUSTOM/themes/powerlevel10k" 2>/dev/null && ok "Powerlevel10k instalado"
    else
        warn "Powerlevel10k ya existe"
    fi

    # Copia el .zshrc DESPUÉS de oh-my-zsh para no perderlo
    cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
    ok ".zshrc copiado"

    # Cambiar shell a zsh
    if [[ "$SHELL" != "$(command -v zsh)" ]]; then
        sudo chsh -s "$(command -v zsh)" "$USER"
        ok "Shell cambiado a ZSH (efectivo al reiniciar sesión)"
    fi
}

# ─── Sesión BSPWM en el display manager ──────────────────────────────────────
register_bspwm() {
    step "Registrando sesión BSPWM..."
    local DK="/usr/share/xsessions/bspwm.desktop"
    if [[ ! -f "$DK" ]]; then
        sudo bash -c "cat > $DK" << 'EOF'
[Desktop Entry]
Name=bspwm
Comment=Binary Space Partitioning Window Manager
Exec=bspwm
Type=Application
EOF
        ok "Sesión BSPWM registrada"
    else
        warn "Sesión BSPWM ya registrada"
    fi
}

# ─── Resumen ──────────────────────────────────────────────────────────────────
summary() {
    echo ""
    echo -e "${GRN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GRN}║       ✓  Instalación completada · @Juguitos          ║${NC}"
    echo -e "${GRN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YLW}  IMPORTANTE:${NC}"
    echo "  1. Cierra sesión y vuelve a entrar"
    echo "  2. En el login selecciona la sesión → ${GRN}bspwm${NC}"
    echo "  3. Ejecuta ${CYN}p10k configure${NC} para el prompt"
    echo ""
    echo -e "${CYN}  Atajos principales:${NC}"
    echo "  Super+Enter    → Terminal (Kitty)"
    echo "  Super+D        → Launcher (Rofi)"
    echo "  Super+Shift+F  → Firefox"
    echo "  Super+Shift+B  → Burpsuite"
    echo "  Super+W        → Cerrar ventana"
    echo "  Super+Alt+Q    → Salir BSPWM"
    echo ""
    echo -e "${YLW}  Target HTB:${NC}"
    echo "  settarget 10.10.10.1 Maquina"
    echo "  cleartarget"
    echo ""
    echo -e "${RED}  Reinicia la sesión ahora para que tome efecto.${NC}"
    echo ""
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
    banner
    check_root

    echo -e "${YLW}Este script instalará BSPWM con el tema RX7${NC}"
    echo -e "${RED}Se hará backup de tus configuraciones actuales${NC}"
    echo ""
    read -rp "¿Continuar? [s/N] " confirm
    [[ "$confirm" =~ ^[sS]$ ]] || { warn "Abortado."; exit 0; }

    backup
    install_packages
    install_fonts
    deploy_configs    # ← configs ANTES de zsh para no perderlas
    register_bspwm
    install_zsh       # ← zsh AL FINAL para que no interrumpa nada
    summary
}

main "$@"



