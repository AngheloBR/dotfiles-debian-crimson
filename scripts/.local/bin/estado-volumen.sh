#!/bin/bash
# estado-volumen.sh — salida para el modulo volume de polybar
# Rice Debian Crimson

MUTE=$(LANG=C pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')
VOL=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '[0-9]+(?=%)' | head -1)

ICON_MUTE=$(printf '\uf026')
ICON_UP=$(printf '\uf028')
ICON_DOWN=$(printf '\uf027')

if [ "$MUTE" = "yes" ]; then
    echo "%{F#D70A53}${ICON_MUTE}%{F-} mute"
elif [ "${VOL:-0}" -gt 50 ]; then
    echo "%{F#E8B04B}${ICON_UP}%{F-} $VOL%"
else
    echo "%{F#E8B04B}${ICON_DOWN}%{F-} $VOL%"
fi
