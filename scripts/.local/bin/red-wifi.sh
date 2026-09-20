#!/bin/bash
# red-wifi.sh — estado de la red para polybar (Rice Debian Crimson)
#   sin args  -> imprime icono + nombre de la red (o avion si esta apagada)
#   toggle    -> alterna Wi-Fi (tecla F8, click en la barra y menu F9)

ICON_WIFI=$(printf '\U000f0928')      # nf-md-wifi_strength_4
ICON_WIFI_OFF=$(printf '\U000f092e')  # nf-md-wifi_strength_off
ICON_AVION=$(printf '\U000f001d')     # nf-md-airplane

if [ "$1" = "toggle" ]; then
    if LANG=C nmcli radio wifi | grep -q enabled; then
        nmcli radio wifi off && \
            dunstify -h string:x-dunst-stack-tag:avion "${ICON_AVION}  Modo avion ACTIVADO"
    else
        nmcli radio wifi on && \
            dunstify -h string:x-dunst-stack-tag:avion "${ICON_WIFI}  Wi-Fi ENCENDIDO"
    fi
    exit 0
fi

# radio apagada -> modo avion
if ! LANG=C nmcli radio wifi 2>/dev/null | grep -q enabled; then
    echo "%{F#D70A53}${ICON_AVION}%{F-}"
    exit 0
fi

# nombre de la conexion Wi-Fi activa (= SSID). Se consulta la conexion,
# no "dev wifi", porque esa forma puede lanzar un escaneo cada refresco.
SSID=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2 ~ /wireless/ {print $1; exit}')
if [ -n "$SSID" ]; then
    echo "%{F#E8B04B}${ICON_WIFI}%{F-} ${SSID:0:14}"
else
    echo "%{F#45474e}${ICON_WIFI_OFF}%{F-}"
fi
