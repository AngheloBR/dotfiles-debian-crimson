#!/bin/bash
# estado-microfono.sh — icono de microfono para polybar
#   muteado: icono tachado en carmesi / normal: icono dorado

MUTE=$(LANG=C pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $2}')

ICON_MIC=$(printf '\uf130')
ICON_MIC_MUTE=$(printf '\uf131')

if [ "$MUTE" = "yes" ]; then
    echo "%{F#D70A53}${ICON_MIC_MUTE}%{F-}"
else
    echo "%{F#E8B04B}${ICON_MIC}%{F-}"
fi
