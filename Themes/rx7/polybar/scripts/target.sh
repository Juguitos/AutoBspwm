#!/usr/bin/env bash
# ─── Target Module · Polybar ─────────────────────────────────────────────────
TARGET_FILE="$HOME/.config/polybar/scripts/target"

case "${1:-show}" in
    clear|clean|reset)
        > "$TARGET_FILE"
        echo "[*] Target limpiado"
        ;;
    copyip)
        [[ ! -s "$TARGET_FILE" ]] && { echo "[-] No hay target definido"; exit 1; }
        ip_addr=$(awk '{print $1}' "$TARGET_FILE")
        echo -n "$ip_addr" | xclip -selection clipboard 2>/dev/null || \
        echo -n "$ip_addr" | xsel --clipboard --input 2>/dev/null
        echo "[+] Copiado: $ip_addr"
        ;;
    show|*)
        if [[ ! -f "$TARGET_FILE" ]] || [[ ! -s "$TARGET_FILE" ]]; then
            echo "󰓯  no target"
        else
            ip_addr=$(awk '{print $1}' "$TARGET_FILE")
            name=$(awk '{print $2}' "$TARGET_FILE")
            [[ -n "$name" ]] && echo "󰓯  $ip_addr  $name" || echo "󰓯  $ip_addr"
        fi
        ;;
esac
