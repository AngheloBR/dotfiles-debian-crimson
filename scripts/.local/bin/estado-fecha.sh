#!/bin/bash
# estado-fecha.sh — fecha + hora para polybar (Rice Debian Crimson)
# El click en la barra (config de polybar) abre el calendario flotante.

ICON=$(printf '\uf017')
echo "%{F#E8B04B}${ICON}%{F-} $(date '+%a %d') · $(date '+%H:%M')"
