#!/bin/bash
# monitor-hotplug.sh — reacciona solo al enchufar/desenchufar el HDMI
# Rice Debian Crimson. Lo arranca bspwmrc.
#
# "bspc subscribe" se queda escuchando los eventos de bspwm; cada vez que
# aparece o desaparece un monitor (bspwm lo sabe por RandR, con
# remove_unplugged_monitors=true) se llama a ajustar-monitores.sh, que ya
# es idempotente. Antes solo se ejecutaba al arrancar o desde F9.
#
# flock -n: si ya hay un ajuste en marcha (el propio ajuste genera
# eventos de monitor al hacer xrandr), el evento se ignora en vez de
# encadenar ejecuciones.
#
# Limite fisico: si el cable sigue enchufado y solo se apaga el monitor,
# el pin de deteccion no cambia y nadie (kernel, X, bspwm) se entera.

LOCK=/tmp/ajustar-monitores.lock
bspc subscribe monitor_add monitor_remove | while read -r _; do
    sleep 1   # dejar que RandR/bspwm terminen de asentar el cambio
    flock -n "$LOCK" ~/.local/bin/ajustar-monitores.sh
done
