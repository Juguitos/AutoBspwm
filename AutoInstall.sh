#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                    AutoBspwm · @Juguitos                                    ║
# ║              BSPWM Auto-Installer for Kali Linux                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
# AVISO: No ejecutes como root. El script pedirá sudo cuando lo necesite.
# Uso:
#   git clone https://github.com/Juguitos/AutoBspwm
#   cd AutoBspwm && bash AutoInstall.sh

set -euo pipefail

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
THEME="rx7"   # único tema disponible

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

check_root() {
    if [[ "$EUID" -eq 0 ]]; then
        err "No ejecutes como root. El script pedirá sudo por su cuenta."
        exit 1
    fi
}

check_os() {
    if ! grep -qi "kali" /etc/os-release 2>/dev/null; then
        warn "Sistema no detectado como Kali Linux."
        read -rp "¿Continuar de todas formas? [s/N] " r
        [[ "$r" =~ ^[sS]$ ]] || exit 0
    fi
}

backup() {
    step "Haciendo backup de configuraciones existentes..."
    mkdir -p "$BACKUP_DIR"
    for item in bspwm sxhkd kitty polybar rofi picom dunst; do
        [[ -d "$CONFIG/$item" ]] && cp -r "$CONFIG/$item" "$BACKUP_DIR/" && ok "Backup: $item"
    done
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$BACKUP_DIR/" && ok "Backup: .zshrc"
    ok "Backups en: $BACKUP_DIR"
}

install_packages() {
    step "Instalando paquetes..."
    sudo apt update -qq
    sudo apt install -y \
        bspwm sxhkd polybar rofi kitty \
        zsh zsh-autosuggestions zsh-syntax-highlighting \
        feh picom dunst libnotify-bin \
        lxappearance papirus-icon-theme \
        fonts-font-awesome \
        thunar xclip xdotool wmctrl \
        flameshot btop htop neofetch \
        bat fd-find ripgrep fzf \
        git curl wget unzip python3-pip \
        i3lock-fancy pamixer playerctl \
        --no-install-recommends 2>&1 | grep -E "^(Get|Unpacking|Setting)" || true
    ok "Paquetes instalados"

    # eza
    if ! command -v eza &>/dev/null; then
        warn "Instalando eza..."
        EZA_URL=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest \
            | grep "browser_download_url" | grep "x86_64-unknown-linux-gnu.tar.gz" \
            | cut -d'"' -f4 | head -1)
        [[ -n "$EZA_URL" ]] && curl -sL "$EZA_URL" -o /tmp/eza.tar.gz && \
            tar -xzf /tmp/eza.tar.gz -C /tmp && sudo mv /tmp/eza /usr/local/bin/eza && ok "eza instalado"
    fi

    # bat → batcat symlink
    if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
        mkdir -p ~/.local/bin
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
        ok "bat enlazado"
    fi

    # fd → fdfind symlink
    if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        mkdir -p ~/.local/bin
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        ok "fd enlazado"
    fi
}

install_fonts() {
    step "Instalando fuentes..."
    local FONTS_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONTS_DIR"

    # Copia las fuentes del repo
    if [[ -d "$REPO_DIR/fonts/HNF" ]]; then
        cp -r "$REPO_DIR/fonts/HNF/." "$FONTS_DIR/"
        ok "HNF fonts copiadas"
    fi
    if [[ -d "$REPO_DIR/Fonts2/fonts" ]]; then
        cp -r "$REPO_DIR/Fonts2/fonts/." "$FONTS_DIR/"
        ok "Fonts2 copiadas"
    fi

    # JetBrains Mono Nerd Font si no está
    if ! fc-list | grep -qi "JetBrainsMono"; then
        info "Descargando JetBrains Mono Nerd Font..."
        curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" \
            -o /tmp/JetBrainsMono.tar.xz
        tar -xf /tmp/JetBrainsMono.tar.xz -C "$FONTS_DIR"
        ok "JetBrains Mono instalada"
    else
        warn "JetBrains Mono ya instalada"
    fi

    fc-cache -fv &>/dev/null
    ok "Caché de fuentes actualizado"
}

install_zsh() {
    step "Instalando ZSH + Oh-My-Zsh + Powerlevel10k..."

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
            "" --unattended
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
        local name="${entry%%|*}" url="${entry##*|}"
        [[ ! -d "$ZSH_CUSTOM/plugins/$name" ]] && \
            git clone --depth=1 "$url" "$ZSH_CUSTOM/plugins/$name" && ok "Plugin: $name" || \
            warn "Plugin ya existe: $name"
    done

    [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]] && \
        git clone --depth=1 https://github.com/romkatv/powerlevel10k \
        "$ZSH_CUSTOM/themes/powerlevel10k" && ok "Powerlevel10k instalado" || \
        warn "Powerlevel10k ya existe"

    [[ "$SHELL" != "$(command -v zsh)" ]] && chsh -s "$(command -v zsh)" && ok "Shell → ZSH"
}

apply_theme() {
    step "Aplicando tema: $THEME..."
    local THEME_DIR="$REPO_DIR/Themes/$THEME"

    if [[ ! -d "$THEME_DIR" ]]; then
        err "Tema no encontrado: $THEME_DIR"
        exit 1
    fi

    # Crear directorios destino
    mkdir -p \
        "$CONFIG/bspwm/scripts" \
        "$CONFIG/sxhkd" \
        "$CONFIG/kitty" \
        "$CONFIG/polybar/scripts" \
        "$CONFIG/rofi" \
        "$CONFIG/picom" \
        "$CONFIG/dunst" \
        "$HOME/.config/Wallpaper"

    # Copiar configs del tema
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

    # zshrc
    cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"

    # Wallpaper
    if [[ -f "$REPO_DIR/Wallpaper/rx7.jpg" ]]; then
        cp "$REPO_DIR/Wallpaper/rx7.jpg" "$HOME/.config/Wallpaper/rx7.jpg"
        ok "Wallpaper copiado"
    fi

    # Permisos
    chmod +x "$CONFIG/bspwm/bspwmrc"
    chmod +x "$CONFIG/bspwm/scripts/bspwm_resize"
    chmod +x "$CONFIG/polybar/launch.sh"
    chmod +x "$CONFIG/polybar/scripts/vpn.sh"
    chmod +x "$CONFIG/polybar/scripts/target.sh"

    # Archivo target vacío
    touch "$CONFIG/polybar/scripts/target"

    ok "Tema '$THEME' aplicado"
}

register_bspwm() {
    step "Registrando sesión BSPWM..."
    local DK="/usr/share/xsessions/bspwm.desktop"
    if [[ ! -f "$DK" ]]; then
        sudo bash -c "cat > $DK << 'EOF'
[Desktop Entry]
Name=bspwm
Comment=Binary Space Partitioning Window Manager
Exec=bspwm
Type=Application
EOF"
        ok "Sesión BSPWM registrada"
    else
        warn "Sesión BSPWM ya registrada"
    fi
}

print_summary() {
    echo ""
    echo -e "${GRN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GRN}║         ✓  Instalación completada · @Juguitos        ║${NC}"
    echo -e "${GRN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYN}Próximos pasos:${NC}"
    echo "  1. Reinicia y selecciona 'bspwm' en el login"
    echo "  2. Ejecuta ${YLW}p10k configure${NC} para configurar el prompt"
    echo "  3. Pon tu wallpaper en ${YLW}~/.config/Wallpaper/rx7.jpg${NC}"
    echo ""
    echo -e "${CYN}Atajos principales:${NC}"
    echo "  Super+Enter    → Terminal"
    echo "  Super+D        → Launcher"
    echo "  Super+E        → Archivos"
    echo "  Super+Shift+F  → Firefox"
    echo "  Super+Shift+B  → Burpsuite"
    echo ""
    echo -e "${YLW}Target (polybar):${NC}"
    echo "  settarget 10.10.10.1 Maquina"
    echo "  cleartarget"
    echo ""
}

main() {
    banner
    check_root
    check_os

    echo -e "${YLW}Este script instalará BSPWM con el tema RX7${NC}"
    echo -e "${RED}Se hará backup de tus configuraciones actuales${NC}"
    echo ""
    read -rp "¿Continuar? [s/N] " confirm
    [[ "$confirm" =~ ^[sS]$ ]] || { warn "Abortado."; exit 0; }

    backup
    install_packages
    install_fonts
    install_zsh
    apply_theme
    register_bspwm
    print_summary
}

main "$@"
