#!/bin/bash
# ajustar-monitores.sh — adapta el escritorio a los monitores presentes
# Rice "Debian Crimson"
#
# Regla de la casa: TODO vive en la laptop (eDP).
# El HDMI, si esta conectado, solo muestra wallpaper:
# un escritorio vacio y SIN barra.
#
# Lo llama bspwmrc al arrancar y el menu F9 ("Detectar monitores").

sleep 0.3   # estabilizar xrandr/X (utile al arrancar la sesion)

ICON_EXTERNO=$(printf '\U000f0379')   # nf-md-monitor

CONECTADOS=$(xrandr | awk '/ connected/ {print $1}')
HDMI_CONECTADO=$(echo "$CONECTADOS" | grep -x 'HDMI-A-0')

if [ -n "$HDMI_CONECTADO" ]; then
    # activarlo a la derecha de la laptop (idempotente)
    xrandr --output HDMI-A-0 --mode 1920x1080 --right-of eDP 2>/dev/null
else
    # sin cable: apagar la salida (mata el monitor fantasma)
    xrandr --output HDMI-A-0 --off 2>/dev/null
fi

sleep 0.7   # dejar que bspwm procese el evento de monitores

if [ -n "$HDMI_CONECTADO" ] && bspc query -M --names | grep -qx 'HDMI-A-0'; then
    # asegurar UN escritorio vacio en el HDMI con su icono
    IDS=$(bspc query -m HDMI-A-0 -D)
    N=$(echo "$IDS" | grep -c .)
    if [ "$N" -eq 0 ]; then
        bspc monitor HDMI-A-0 -a "$ICON_EXTERNO"
    elif [ "$N" -eq 1 ]; then
        DID=$(echo "$IDS" | head -1)
        if [ "$(bspc query -d "$DID" -D --names)" != "$ICON_EXTERNO" ]; then
            bspc desktop "$DID" --rename "$ICON_EXTERNO"
        fi
    fi
else
    # el HDMI se fue: bspwm movio su escritorio a eDP.
    # Eliminar el huerfano (con sus ventanas de vuelta al escritorio 1)
    for DID in $(bspc query -m eDP -D); do
        if [ "$(bspc query -d "$DID" --name)" = "$ICON_EXTERNO" ]; then
            if [ -n "$(bspc query -d "$DID" -N)" ]; then
                for NID in $(bspc query -d "$DID" -N); do
                    bspc node "$NID" -d eDP:^1
                done
            fi
            bspc desktop "$DID" -r
        fi
    done
fi

# barras: solo la de la laptop (el HDMI no lleva barra)
pkill -x polybar 2>/dev/null
sleep 0.4
setsid polybar main >/dev/null 2>&1 < /dev/null &

# re-aplicar el wallpaper al nuevo acomodo de monitores
~/.local/bin/fondo.sh >/dev/null 2>&1
