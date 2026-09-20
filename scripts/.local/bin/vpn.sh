#!/bin/bash
# vpn.sh — estado y menu de VPN para polybar (Rice Debian Crimson)
#   sin args -> icono + nombre si hay una VPN activa; nada si no
#   menu     -> rofi para conectar/desconectar
#
# MODULAR: no depende de un proveedor. Detecta la VPN activa por la
# INTERFAZ de red (cualquier VPN crea una), asi funciona con lo que sea:
#   tun*/tap*   openvpn, proton, la mayoria de clientes
#   wg*         wireguard (wg-quick)
#   tailscale0  tailscale
#   wt0 / nb*   netbird
# Y el menu ofrece los "backends" que esten instalados en ese momento:
#   - conexiones VPN/WireGuard importadas en NetworkManager (nmcli)
#   - tailscale up/down       (si existe el comando)
#   - netbird up/down         (si existe el comando)
#   - configs en /etc/wireguard/*.conf via wg-quick (si existen)
# Añadir otro = una funcion mas abajo.

I_ON=$(printf '\U000f0582')    # nf-md-shield_check
I_OFF=$(printf '\U000f0581')   # nf-md-shield_outline (menu sin vpn)
I_UP=$(printf '\U000f0337')    # nf-md-link
I_DOWN=$(printf '\U000f0338')  # nf-md-link_off
# array (no cadena): asi los argumentos llegan enteros a dunstify sin
# depender de la division por espacios de la shell
TAG=(-h "string:x-dunst-stack-tag:vpn")

# interfaz de VPN activa (la primera que haya), o vacio
iface_vpn() {
    ip -o link show up 2>/dev/null | awk -F': ' '{print $2}' | \
        grep -E -m1 '^(tun|tap|wg|tailscale|wt|nb)[0-9a-z-]*$'
}

# nombre legible para una interfaz
nombre_vpn() {
    case "$1" in
        tailscale*) echo "tailscale" ;;
        wt*|nb*)    echo "netbird" ;;
        *)  # NetworkManager sabe el nombre de lo que levanto el
            local n; n=$(nmcli -t -f NAME,DEVICE con show --active 2>/dev/null | awk -F: -v i="$1" '$2==i{print $1; exit}')
            echo "${n:-$1}" ;;
    esac
}

if [ "$1" != "menu" ]; then
    IF=$(iface_vpn)
    [ -z "$IF" ] && exit 0                      # sin VPN: modulo oculto
    echo "%{F#E8B04B}${I_ON}%{F-} $(nombre_vpn "$IF")"
    exit 0
fi

# ── menu ──
IF=$(iface_vpn)
OPC=(); CMD=()
if [ -n "$IF" ]; then
    OPC+=("${I_DOWN}  Desconectar $(nombre_vpn "$IF")")
    case "$IF" in
        tailscale*) CMD+=("tailscale down") ;;
        wt*|nb*)    CMD+=("netbird down") ;;
        wg*)        if nmcli -t -f DEVICE con show --active 2>/dev/null | grep -qx "$IF"; then
                        CMD+=("nmcli con down id \"$(nombre_vpn "$IF")\"")
                    else CMD+=("sudo wg-quick down $IF"); fi ;;
        *)          CMD+=("nmcli con down id \"$(nombre_vpn "$IF")\"") ;;
    esac
fi
# conexiones VPN de NetworkManager (importadas con: nmcli con import type openvpn|wireguard file X)
while IFS=: read -r nombre tipo; do
    [ "$nombre" = "$(nombre_vpn "$IF")" ] && continue
    OPC+=("${I_UP}  $nombre ($tipo)"); CMD+=("nmcli con up id \"$nombre\"")
done < <(nmcli -t -f NAME,TYPE con show 2>/dev/null | grep -E ':(vpn|wireguard)$' | sed 's/:wireguard$/:wireguard/; s/:vpn$/:vpn/')
command -v tailscale >/dev/null && [ "$(nombre_vpn "$IF")" != "tailscale" ] && { OPC+=("${I_UP}  Tailscale"); CMD+=("tailscale up"); }
command -v netbird   >/dev/null && [ "$(nombre_vpn "$IF")" != "netbird" ]   && { OPC+=("${I_UP}  NetBird");   CMD+=("netbird up"); }
for f in /etc/wireguard/*.conf; do
    [ -e "$f" ] || continue; n=$(basename "${f%.conf}")
    [ "$n" = "$IF" ] && continue
    OPC+=("${I_UP}  WireGuard: $n"); CMD+=("sudo wg-quick up $n")
done

if [ ${#OPC[@]} -eq 0 ]; then
    dunstify "${TAG[@]}" "${I_OFF}  Sin VPN configurada" "Importa una: nmcli con import type openvpn file X.ovpn (o wireguard)"
    exit 0
fi

N=${#OPC[@]}; [ "$N" -gt 8 ] && N=8
IDX=$(printf '%s\n' "${OPC[@]}" | rofi -dmenu -i -format i -p " ${I_ON}  VPN " \
    -theme-str "listview { columns: 1; lines: $N; } element { orientation: horizontal; }")
[ -z "$IDX" ] && exit 0
dunstify "${TAG[@]}" "${I_ON}  ${OPC[$IDX]#*  }..."
if eval "${CMD[$IDX]}" >/dev/null 2>&1; then
    dunstify "${TAG[@]}" "${I_ON}  VPN: ${OPC[$IDX]#*  } listo"
else
    dunstify -u critical "${TAG[@]}" "${I_OFF}  Fallo: ${OPC[$IDX]#*  }"
fi
