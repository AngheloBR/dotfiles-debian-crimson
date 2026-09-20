#!/bin/bash
# monitor-hotplug.sh — reacciona solo al enchufar/desenchufar el HDMI
# Rice Debian Crimson. Lo arranca bspwmrc.
#
# Fuente del evento: el KERNEL (udev, subsistema drm), no bspwm. Al quitar
# el cable, X marca la salida como "disconnected" pero NO la apaga: sigue
# con su resolucion asignada, y bspwm solo olvida monitores apagados. Por
# eso bspwm no emite monitor_remove y hay que llamar a ajustar-monitores.sh
# (que hace el "xrandr --off") desde el evento del kernel.
#
# udevadm monitor no necesita root. Los eventos se atienden en serie (el
# while los va leyendo uno a uno) y ajustar-monitores.sh es idempotente,
# asi que no hace falta candado. OJO: NO usar flock aqui: el ajuste lanza
# polybar, que heredaria el descriptor del candado y lo dejaria cogido
# para siempre (su modulo de musica vive en modo tail).
#
# Limite fisico: si el cable sigue enchufado y solo se apaga el monitor,
# el pin de deteccion no cambia y no hay evento.

LOG=~/.cache/monitor-hotplug.log   # que evento llego y que hizo el ajuste
udevadm monitor --udev --subsystem-match=drm 2>/dev/null | \
while read -r linea; do
    case "$linea" in
        *change*)
            sleep 1   # dejar que X actualice el estado de la salida
            {
                echo "── $(date '+%F %T') evento: $linea"
                xrandr | grep -E ' (connected|disconnected)'
                ~/.local/bin/ajustar-monitores.sh && echo "ajuste OK"
            } >> "$LOG" 2>&1
            # el registro no crece sin limite: ultimas 100 lineas
            tail -n 100 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG" ;;
    esac
done
