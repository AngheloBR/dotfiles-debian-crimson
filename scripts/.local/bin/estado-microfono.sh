#!/bin/bash
# estado-microfono.sh — icono de microfono para polybar (Rice Debian Crimson)
#   silenciado: icono tachado carmesi / activo: icono dorado

ICON_MIC=$(printf '\U000f036c')      # nf-md-microphone
ICON_MIC_OFF=$(printf '\U000f036d')  # nf-md-microphone_off

if [ "$(LANG=C pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $2}')" = "yes" ]; then
    echo "%{F#D70A53}${ICON_MIC_OFF}%{F-}"
else
    echo "%{F#E8B04B}${ICON_MIC}%{F-}"
fi
