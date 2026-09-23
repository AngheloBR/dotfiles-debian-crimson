#!/bin/bash
# no-molestar.sh — pausar las notificaciones (Rice Debian Crimson)
#   sin args -> icono para polybar: solo se muestra si esta activo
#   toggle   -> activar/desactivar (super + shift + d, click en el icono)
#
# dunst las guarda mientras esta en pausa y las muestra todas al quitarla.

ICON_ON=$(printf '\U000f009b')    # nf-md-bell_off
ICON_OFF=$(printf '\U000f009a')   # nf-md-bell

command -v dunstctl >/dev/null || { echo ""; exit 0; }   # sin dunst: modulo vacio

if [ "$1" = "toggle" ]; then
    dunstctl set-paused toggle
    if [ "$(dunstctl is-paused)" = "true" ]; then
        # no se puede notificar en pausa: aviso corto ANTES de que aplique...
        # (set-paused es inmediato, asi que usamos el icono de la barra)
        polybar-msg action dnd exec >/dev/null 2>&1
    else
        polybar-msg action dnd exec >/dev/null 2>&1
        dunstify -h string:x-dunst-stack-tag:dnd "${ICON_OFF}  Notificaciones activas de nuevo"
    fi
    exit 0
fi

# modulo: visible solo en pausa (carmesi), asi no ocupa sitio el resto del tiempo
[ "$(dunstctl is-paused 2>/dev/null)" = "true" ] && echo "%{F#D70A53}${ICON_ON}%{F-}"
exit 0
