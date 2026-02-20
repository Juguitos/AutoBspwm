#!/bin/bash

# Polybar Power Menu Script · RX7 Theme

option=$(echo -e "⏻  Apagar\n󰜉  Reiniciar\n󰍃  Cerrar sesión\n󰌾  Bloquear" | rofi -dmenu -i -p " Power" -theme ~/.config/rofi/powermenu.rasi)

case "$option" in
    "⏻  Apagar")
        systemctl poweroff
        ;;
    "󰜉  Reiniciar")
        systemctl reboot
        ;;
    "󰍃  Cerrar sesión")
        bspc quit
        ;;
    "󰌾  Bloquear")
        i3lock-fancy 2>/dev/null || betterlockscreen -l 2>/dev/null || slock
        ;;
esac
