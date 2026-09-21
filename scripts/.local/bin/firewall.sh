#!/bin/bash
# firewall.sh — perfil del firewall para polybar y el menu F9
# Rice Debian Crimson
#   sin args -> icono + perfil (dorado = privada, carmesi = publica)
#   menu     -> rofi: forzar perfil, marcar/olvidar la red actual
#
# El cambio real lo hace /usr/local/sbin/firewall-perfil (root, via sudo
# sin contraseña solo para ese script). Ademas, NetworkManager lo llama
# solo en cada conexion: red de confianza -> privada, desconocida -> publica.

I_PRIV=$(printf '\U000f068a')    # nf-md-shield_home
I_PUB=$(printf '\U000f099d')     # nf-md-shield_lock
I_TRUST=$(printf '\U000f012c')   # nf-md-check
I_FORGET=$(printf '\U000f01b4')  # nf-md-delete
I_OFF=$(printf '\U000f099e')     # nf-md-shield_off
TAG=(-h "string:x-dunst-stack-tag:firewall")
FP="sudo -n /usr/local/sbin/firewall-perfil"

perfil() { cat /run/firewall-perfil 2>/dev/null || echo publica; }
ssid()   { nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2=="802-11-wireless"{print $1; exit}'; }

if [ "$1" != "menu" ]; then
    systemctl is-active -q nftables || exit 0            # sin firewall: oculto
    case "$(perfil)" in
        privada) echo "%{F#E8B04B}${I_PRIV}%{F-}" ;;
        apagado) echo "%{F#45474e}${I_OFF}%{F-} off" ;;
        *)       echo "%{F#D70A53}${I_PUB}%{F-}" ;;
    esac
    exit 0
fi

P=$(perfil); RED=$(ssid)
if grep -qxF "${RED:-__}" /etc/nftables.d/redes-privadas.txt 2>/dev/null; then CONF="de confianza"; else CONF="desconocida"; fi
OPC=("${I_PRIV}  Privada (casa, amigos, celular)" "${I_PUB}  Publica (plaza, cafe, calle)" "${I_OFF}  APAGAR firewall (emergencia: si te quedas sin red)")
[ -n "$RED" ] && if [ "$CONF" = "de confianza" ]; then
    OPC+=("${I_FORGET}  Olvidar red \"$RED\" (dejara de ser privada)")
else
    OPC+=("${I_TRUST}  Marcar red \"$RED\" como privada")
fi
IDX=$(printf '%s\n' "${OPC[@]}" | rofi -dmenu -i -format i \
    -p " $([ "$P" = privada ] && echo "$I_PRIV" || echo "$I_PUB")  Firewall: $P · red ${RED:-sin wifi} ($CONF) " \
    -theme-str "listview { columns: 1; lines: ${#OPC[@]}; } element { orientation: horizontal; }")
[ -z "$IDX" ] && exit 0
case "$IDX" in
    0) R=$($FP privada) && dunstify "${TAG[@]}" "${I_PRIV}  Firewall: perfil PRIVADA" "Visible en la red local (ping, impresora). Se re-evalua al cambiar de red." ;;
    1) R=$($FP publica) && dunstify "${TAG[@]}" "${I_PUB}  Firewall: perfil PUBLICA" "Invisible: solo respuestas a lo que pidas." ;;
    2) R=$($FP apagar) && dunstify -u critical "${TAG[@]}" "${I_OFF}  Firewall APAGADO" "Todo pasa. Se reactiva solo al cambiar de red o desde este menu." ;;
    3) if [ "$CONF" = "de confianza" ]; then
           R=$($FP olvidar "$RED") && dunstify "${TAG[@]}" "${I_FORGET}  \"$RED\" ya no es de confianza" "Perfil ahora: $R"
       else
           R=$($FP confiar "$RED") && dunstify "${TAG[@]}" "${I_TRUST}  \"$RED\" marcada como privada" "Perfil ahora: $R"
       fi ;;
esac
[ -z "$R" ] && dunstify -u critical "${TAG[@]}" "${I_PUB}  No se pudo cambiar el firewall" "¿Esta instalado /usr/local/sbin/firewall-perfil y el sudoers?"
polybar-msg action firewall exec >/dev/null 2>&1   # refrescar el icono ya
