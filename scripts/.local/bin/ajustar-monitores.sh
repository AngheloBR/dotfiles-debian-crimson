#!/bin/bash
# ajustar-monitores.sh — adapta el escritorio a los monitores presentes
# Rice "Debian Crimson"
#
# Regla de la casa: TODO vive en el monitor interno (el primario: eDP en
# la laptop, Virtual-1 en una VM). Un monitor externo, si esta conectado,
# solo muestra wallpaper: un escritorio vacio y SIN barra.
#
# Lo llaman: bspwmrc al arrancar, monitor-hotplug.sh al enchufar/quitar
# un cable, y el menu F9 ("Detectar monitores").

sleep 0.3   # estabilizar xrandr/X (util al arrancar la sesion)

ICON_EXTERNO=$(printf '\U000f0379')   # nf-md-monitor
INTERNO=$(~/.local/bin/monitor-interno.sh)
[ -z "$INTERNO" ] && exit 1

# salidas conectadas que no son la interna (HDMI-A-0, DisplayPort-0...)
EXTERNOS=$(xrandr --query | awk '/ connected/{print $1}' | grep -vx "$INTERNO")
# salidas SIN cable que X aun tiene encendidas (conservan su modo tras
# quitar el cable): apagarlas, si no bspwm sigue creyendo que existen
for OUT in $(xrandr --query | awk '/ disconnected [0-9]+x[0-9]+/{print $1}'); do
    xrandr --output "$OUT" --off 2>/dev/null
done
# externos: a la derecha del interno (idempotente)
for OUT in $EXTERNOS; do
    xrandr --output "$OUT" --auto --right-of "$INTERNO" 2>/dev/null
done

sleep 0.7   # dejar que bspwm procese el evento de monitores

# 1) limpiar SIEMPRE escritorios huerfanos con el icono del externo en el
#    interno (bspwm los mueve ahi al quitar el externo). Ventanas al esc. 1.
for DID in $(bspc query -m "$INTERNO" -D); do
    if [ "$(bspc query -d "$DID" -D --names)" = "$ICON_EXTERNO" ]; then
        for NID in $(bspc query -d "$DID" -N -n .window); do
            bspc node "$NID" -d "$INTERNO:^1"
        done
        bspc desktop "$DID" -r
    fi
done

# 2) cada externo presente: UN escritorio vacio con su icono
for OUT in $EXTERNOS; do
    bspc query -M --names | grep -qx "$OUT" || continue
    IDS=$(bspc query -m "$OUT" -D)
    if [ -z "$IDS" ]; then
        bspc monitor "$OUT" -a "$ICON_EXTERNO"
    else
        DID=$(echo "$IDS" | head -1)
        [ "$(bspc query -d "$DID" -D --names)" != "$ICON_EXTERNO" ] && bspc desktop "$DID" --rename "$ICON_EXTERNO"
        for EXTRA in $(echo "$IDS" | tail -n +2); do bspc desktop "$EXTRA" -r; done
    fi
done

# barra: solo en el interno (polybar lee MONITOR de la config)
pkill -x polybar 2>/dev/null
sleep 0.4
MONITOR="$INTERNO" setsid polybar main >/dev/null 2>&1 < /dev/null &

# re-aplicar el wallpaper al nuevo acomodo de monitores
~/.local/bin/fondo.sh >/dev/null 2>&1
