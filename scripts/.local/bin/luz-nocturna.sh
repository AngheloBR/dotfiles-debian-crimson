#!/bin/bash
# luz-nocturna.sh — gammastep para polybar y el menu F9 (Rice Debian Crimson)
#   sin args -> icono: dorado = calido AHORA (noche), tenue = de dia
#               (6500K, sin efecto), gris = en pausa; nada sin gammastep
#   toggle   -> alterna (click en el icono / F9)
#
# De dia gammastep esta activo pero en 6500K (neutro): no se nota nada,
# y es lo esperado. "gammastep -p" imprime la temperatura que toca ahora.
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
    exit 0
fi
TEMP=$(gammastep -p 2>/dev/null | grep -oE '[0-9]+K' | tr -d K)
if [ -n "$TEMP" ] && [ "$TEMP" -lt 6500 ]; then
    echo "%{F#E8B04B}${I_ON}%{F-}"        # calido: se nota
else
    echo "%{F#7a7a80}${I_ON}%{F-}"        # de dia: activo pero neutro
fi
