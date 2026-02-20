# AutoBspwm · @Juguitos

Script de instalación automática de BSPWM para **Kali Linux** con el tema **RX7**.

> ⚠️ No ejecutes el script como root. El script pedirá sudo cuando lo necesite.

## Preview

![rx7](Wallpaper/rx7.jpg)

## Instalación

```bash
git clone https://github.com/Juguitos/AutoBspwm
cd AutoBspwm
chmod +x AutoInstall.sh
./AutoInstall.sh
```

Después del reboot, selecciona **bspwm** en el display manager.

## Lo que instala

- **WM**: BSPWM + SXHKD
- **Bar**: Polybar (target HTB, VPN, IP, CPU, RAM, volumen)
- **Terminal**: Kitty
- **Launcher**: Rofi
- **Compositor**: Picom
- **Notificaciones**: Dunst
- **Shell**: ZSH + Oh-My-Zsh + Powerlevel10k
- **Editor**: Neovim (opcional, con config para pentesting)
- **Fetch**: Fastfetch con logo RX7 personalizado
- **Fuentes**: JetBrains Mono Nerd Font + HNF + Helvetica
- **File manager**: Thunar
- **Portapapeles**: open-vm-tools (VMware copy/paste)

## Estructura

```
AutoBspwm/
├── AutoInstall.sh          ← instalador principal
├── .zshrc                  ← config de shell + funciones HTB
├── Themes/
│   └── rx7/               ← tema RX7
│       ├── bspwm/
│       │   └── scripts/   ← bspwm_resize
│       ├── sxhkd/
│       ├── kitty/
│       ├── polybar/
│       │   └── scripts/   ← target.sh, vpn.sh
│       ├── rofi/
│       ├── picom/
│       └── dunst/
├── fastfetch/
│   ├── config.jsonc        ← config con iconos HTB
│   └── rx7.txt             ← logo ASCII personalizado
├── nvim/                   ← config neovim (opcional)
├── Wallpaper/
│   └── rx7.jpg
├── Fonts2/fonts/
└── fonts/HNF/
```

## Atajos principales

| Atajo | Acción |
|-------|--------|
| `Super + Enter` | Terminal (Kitty) |
| `Super + D` | Launcher (Rofi) |
| `Super + E` | Archivos (Thunar) |
| `Super + Shift+F` | Firefox |
| `Super + Shift+B` | Burpsuite |
| `Ctrl + Shift+P` | Burpsuite Pro |
| `Super + B` | Btop |
| `Super + H/J/K/L` | Navegar ventanas |
| `Super + Flechas` | Navegar ventanas |
| `Super + 1-9` | Cambiar workspace |
| `Super + Shift+1-9` | Mover ventana a workspace |
| `Super + W` | Cerrar ventana |
| `Super + F` | Fullscreen |
| `Super + S` | Flotante |
| `Super + M` | Monocle |
| `Alt + Super + Flechas` | Redimensionar ventana |
| `Ctrl + Shift+Up/Down` | Volumen +/- |
| `Ctrl + Shift+M` | Mute |
| `Print` | Screenshot completo |
| `Ctrl + Print` | Screenshot región |
| `Ctrl + Alt+L` | Lockscreen |
| `Super + Ctrl+T` | Copiar IP target |
| `Super + Shift+Delete` | Limpiar target |
| `Super + Shift+I` | Copiar IP VPN (tun0) |
| `Super + I` | Copiar IP local |
| `Super + Alt+Q` | Salir BSPWM |
| `Super + Alt+R` | Reiniciar BSPWM |

## Funciones ZSH para hacking

```bash
# ── Target (se muestra en polybar en tiempo real) ───
settarget 10.10.10.1              # solo IP
settarget 10.10.10.1 Maquina     # IP + nombre
cleartarget                       # limpia target
st / ct                           # alias cortos

# ── Workspaces ──────────────────────────────────────
mkhtb <nombre>    # crea workspace HTB (nmap/exploits/loot/www/notes)
mktb <nombre>     # crea workspace TryHackMe

# ── Reconocimiento ──────────────────────────────────
nmapscan [ip]     # nmap automático con salida a ./nmap/
revshell [ip] [p] # genera reverse shells (bash/python/nc/php)
listen [puerto]   # listener netcat (default 4444)
shell_upgrade     # instrucciones TTY upgrade post-RCE
```

## Neovim (opcional)

Si seleccionas **Sí** al instalar nvim, incluye:
- Colorscheme TokyoNight con colores HTB
- LSP para bash y python
- Autocompletado con snippets
- Telescope, NvimTree, ToggleTerm
- `Space+sb` → shebang bash · `Space+x` → ejecutar script

## Componentes base

- bspwm, sxhkd, picom, polybar, feh
- kitty, rofi, dunst, thunar
- JetBrains Mono Nerd Font
- open-vm-tools (portapapeles VMware)

---

## Créditos

Inspirado en el trabajo de **[ZLCube](https://github.com/ZLCube/AutoBspwm)**, cuyo repo AutoBspwm fue la referencia principal para la estructura y enfoque de este proyecto.

---

**@Juguitos** · Kali Linux · HTB
