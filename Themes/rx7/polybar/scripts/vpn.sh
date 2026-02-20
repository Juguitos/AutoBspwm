#!/usr/bin/env bash
VPN_IP=$(ip -4 a show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
if [[ -n "$VPN_IP" ]]; then
    echo "󰦝 $VPN_IP"
else
    echo "󰦞 no vpn"
fi
