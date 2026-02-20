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
- **Bar**: Polybar (con módulos: target HTB, VPN, IP, CPU, RAM, volumen)
- **Terminal**: Kitty
- **Launcher**: Rofi
- **Compositor**: Picom
- **Notificaciones**: Dunst
- **Shell**: ZSH + Oh-My-Zsh + Powerlevel10k
- **Fuentes**: JetBrains Mono Nerd Font + HNF + Helvetica
- **File manager**: Thunar

## Estructura

```
AutoBspwm/
├── AutoInstall.sh          ← instalador principal
├── .zshrc                  ← config de shell
├── Themes/
│   └── rx7/               ← tema RX7
│       ├── bspwm/
│       ├── sxhkd/
│       ├── kitty/
│       ├── polybar/
│       │   └── scripts/   ← target.sh, vpn.sh
│       ├── rofi/
│       ├── picom/
│       └── dunst/
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
| `Super + B` | Btop |
| `Super + H/J/K/L` | Navegar ventanas |
| `Super + 1-9` | Cambiar workspace |
| `Super + W` | Cerrar ventana |
| `Super + F` | Fullscreen |
| `Super + S` | Flotante |
| `Ctrl + Shift+Up/Down` | Volumen |
| `Print` | Screenshot |
| `Ctrl + Print` | Screenshot región |
| `Ctrl + Alt+L` | Lockscreen |
| `Super + Ctrl+T` | Copiar IP target |
| `Super + Shift+I` | Copiar IP VPN |
| `Super + Alt+Q` | Salir BSPWM |

## Funciones ZSH para hacking

```bash
settarget 10.10.10.1              # Muestra IP en polybar
settarget 10.10.10.1 Maquina     # IP + nombre en polybar
cleartarget                       # Limpia target
st / ct                           # Alias cortos

mkhtb <nombre>    # Crea workspace HTB
mktb <nombre>     # Crea workspace TryHackMe
nmapscan [ip]     # Nmap automático
revshell [ip] [p] # Genera reverse shells
listen [puerto]   # Listener netcat
shell_upgrade     # Instrucciones TTY upgrade
```

## Componentes base

- bspwm, sxhkd, picom, polybar
- kitty, rofi, dunst, feh
- JetBrains Mono Nerd Font

---

**@Juguitos** · Kali Linux · HTB
