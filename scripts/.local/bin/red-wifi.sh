#!/bin/bash
# red-wifi.sh — estado de la red para polybar (Rice Debian Crimson)
#   sin args      -> imprime icono + on/off (o avion si esta apagado)
#   toggle        -> alterna Wi-Fi (lo usa la tecla F8 y el click en la barra)

ICON_WIFI=$(printf '\uf1eb')
ICON_AVION=$(printf '\uf072')

if [ "$1" = "toggle" ]; then
    if LANG=C nmcli radio wifi | grep -q enabled; then
        nmcli radio wifi off && \
            dunstify -h string:x-dunst-stack-tag:avion "Modo avion: Wi-Fi APAGADO"
    else
        nmcli radio wifi on && \
            dunstify -h string:x-dunst-stack-tag:avion "Modo avion: Wi-Fi ENCENDIDO"
    fi
    exit 0
fi

# radio apagada -> modo avion
if ! LANG=C nmcli radio wifi 2>/dev/null | grep -q enabled; then
    echo "%{F#D70A53}${ICON_AVION}%{F-} off"
# con IP -> conectado
elif ip -4 addr show wlp2s0 2>/dev/null | grep -q 'inet '; then
    echo "%{F#E8B04B}${ICON_WIFI}%{F-} on"
# radio on pero sin red -> desconectado
else
    echo "%{F#45474e}${ICON_WIFI}%{F-} off"
fi
