#!/bin/bash
# inhibir-bloqueo.sh — no bloquear la pantalla mientras suena video/musica
# Rice Debian Crimson. Lo arranca bspwmrc.
#
# xss-lock bloquea cuando el salvapantallas de X salta por inactividad
# (600 s, "xset q"). Si hay algo reproduciendose (Firefox/YouTube, mpv...
# cualquier cosa MPRIS), cada 50 s se reinicia el contador de inactividad
# con "xset s reset": mientras dure la pelicula no hay candado.
# En pausa o sin reproductor, el contador sigue normal.

command -v playerctl >/dev/null || exit 0
while true; do
    if [ "$(playerctl status 2>/dev/null)" = "Playing" ]; then
        xset s reset
    fi
    sleep 50
done
