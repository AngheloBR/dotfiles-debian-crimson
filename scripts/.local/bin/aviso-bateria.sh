#!/bin/bash
# aviso-bateria.sh — notifica bateria baja (Rice Debian Crimson)
#
# Lo arranca bspwmrc. Lee /sys cada 60 s (cero coste: no ejecuta nada,
# solo lee dos archivos del kernel) y avisa UNA vez por umbral:
#   20% -> aviso normal      10% -> critico (no se cierra solo)
# Al enchufar el cargador se rearman los avisos.
#
# En Debian 13 no existe "batsignal" en los repos; esto lo reemplaza.

BAT=/sys/class/power_supply/BAT0
[ -r "$BAT/capacity" ] || exit 0     # sin bateria (VM, sobremesa): nada que hacer

ICON_BAJA=$(printf '\U000f0083')     # nf-md-battery_alert
ICON_CARGA=$(printf '\U000f0084')    # nf-md-battery_charging

AVISADO_20=0
AVISADO_10=0

while true; do
    NIVEL=$(<"$BAT/capacity")
    ESTADO=$(<"$BAT/status")          # Charging / Discharging / Not charging / Full

    if [ "$ESTADO" = "Discharging" ]; then
        if [ "$NIVEL" -le 10 ] && [ "$AVISADO_10" -eq 0 ]; then
            dunstify -u critical -h string:x-dunst-stack-tag:bateria \
                "$ICON_BAJA  Bateria al ${NIVEL}%" "Conecta el cargador o suspende ahora"
            AVISADO_10=1
        elif [ "$NIVEL" -le 20 ] && [ "$AVISADO_20" -eq 0 ]; then
            dunstify -h string:x-dunst-stack-tag:bateria \
                "$ICON_BAJA  Bateria al ${NIVEL}%" "Conecta el cargador"
            AVISADO_20=1
        fi
    else
        # enchufada: rearmar para la proxima descarga
        if [ "$AVISADO_20" -eq 1 ] || [ "$AVISADO_10" -eq 1 ]; then
            dunstify -h string:x-dunst-stack-tag:bateria "$ICON_CARGA  Cargando (${NIVEL}%)"
        fi
        AVISADO_20=0
        AVISADO_10=0
    fi

    sleep 60
done
