#!/bin/bash
# estado-temperatura.sh — temperatura de la CPU para polybar (Rice Debian Crimson)
#
# Busca el sensor por NOMBRE (k10temp = CPU AMD) y no por numero de hwmon,
# porque /sys/class/hwmon/hwmonN cambia de numero entre arranques.
# Colores: dorado normal, carmesi a partir de 80 C (aviso de calor).

ICON=$(printf '\U000f050f')   # nf-md-thermometer

for d in /sys/class/hwmon/*; do
    if [ "$(cat "$d/name" 2>/dev/null)" = "k10temp" ]; then
        T=$(( $(cat "$d/temp1_input") / 1000 ))
        if [ "$T" -ge 80 ]; then
            echo "%{F#D70A53}${ICON}%{F-} ${T}°"
        else
            echo "%{F#E8B04B}${ICON}%{F-} ${T}°"
        fi
        exit 0
    fi
done
# sin sensor (VM): modulo vacio
