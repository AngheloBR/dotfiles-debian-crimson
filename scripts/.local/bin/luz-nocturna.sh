#!/bin/bash
# luz-nocturna.sh — gammastep para polybar y el menu F9 (Rice Debian Crimson)
#   sin args -> icono: dorado = activa, gris = en pausa (o sin gammastep)
#   toggle   -> alterna (click en el icono / F9)
#
# gammastep no dice desde fuera si esta en pausa (USR1 alterna sin mas),
# asi que el estado se apunta en ~/.cache/luz-nocturna-pausada.

I_ON=$(printf '\U000f0594')    # nf-md-weather_night
PAUSA=~/.cache/luz-nocturna-pausada

if [ "$1" = "toggle" ]; then
    pgrep -x gammastep >/dev/null || { dunstify "gammastep no esta corriendo"; exit 1; }
    pkill -USR1 -x gammastep
    if [ -f "$PAUSA" ]; then
        rm -f "$PAUSA"; dunstify -h string:x-dunst-stack-tag:noche "${I_ON}  Luz nocturna ACTIVA"
    else
        touch "$PAUSA"; dunstify -h string:x-dunst-stack-tag:noche "${I_ON}  Luz nocturna en pausa"
    fi
    exit 0
fi

pgrep -x gammastep >/dev/null || exit 0        # sin gammastep: oculto
if [ -f "$PAUSA" ]; then
    echo "%{F#45474e}${I_ON}%{F-}"
else
    echo "%{F#E8B04B}${I_ON}%{F-}"
fi
