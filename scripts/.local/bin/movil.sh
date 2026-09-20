#!/bin/bash
# movil.sh — KDE Connect para polybar (Rice Debian Crimson)
#   sin args -> icono + bateria del movil (nada si no esta al alcance)
#   menu     -> rofi: hacer sonar, enviar portapapeles, emparejar...
#
# kdeconnectd expone todo por D-Bus; kdeconnect-cli sirve para lo basico
# y busctl para leer la bateria (la cli no la da).

I_TEL=$(printf '\U000f011c')      # nf-md-cellphone
I_RING=$(printf '\U000f00e1')     # nf-md-bell_ring
I_CLIP=$(printf '\U000f018f')     # nf-md-clipboard_text
I_PAIR=$(printf '\U000f0337')     # nf-md-link
I_BAT=$(printf '\U000f0084')      # nf-md-battery_charging
TAG="-h string:x-dunst-stack-tag:movil"

pgrep -x kdeconnectd >/dev/null || exit 0

# primer dispositivo emparejado Y al alcance
ID=$(kdeconnect-cli -a --id-only 2>/dev/null | head -1)

bateria() {   # -> "85" y "cargando" en $CARGA (vacio si no)
    local base="org.kde.kdeconnect /modules/kdeconnect/devices/$1/battery org.kde.kdeconnect.device.battery"
    NIVEL=$(busctl --user get-property $base charge 2>/dev/null | awk '{print $2}')
    CARGA=$(busctl --user get-property $base isCharging 2>/dev/null | awk '{print $2}')
}

if [ "$1" != "menu" ]; then
    [ -z "$ID" ] && exit 0
    bateria "$ID"
    if [ -z "$NIVEL" ] || [ "$NIVEL" -lt 0 ]; then echo "%{F#E8B04B}${I_TEL}%{F-}"; exit 0; fi
    COLOR="#E8B04B"; [ "$NIVEL" -le 20 ] && [ "$CARGA" != "true" ] && COLOR="#D70A53"
    SUF=""; [ "$CARGA" = "true" ] && SUF="${I_BAT}"
    echo "%{F$COLOR}${I_TEL}%{F-} ${NIVEL}%${SUF}"
    exit 0
fi

# ── menu ──
if [ -z "$ID" ]; then
    NOMBRES=$(kdeconnect-cli -l 2>/dev/null | grep -c '^- ')
    OPC=("${I_PAIR}  Buscar y emparejar (${NOMBRES} visibles)")
    IDX=$(printf '%s\n' "${OPC[@]}" | rofi -dmenu -i -format i -p " ${I_TEL}  Movil " \
        -theme-str "listview { columns: 1; lines: 1; } element { orientation: horizontal; }")
    [ -z "$IDX" ] && exit 0
    kdeconnect-cli --refresh >/dev/null 2>&1; sleep 2
    CAND=$(kdeconnect-cli -a --id-only 2>/dev/null | head -1)
    if [ -z "$CAND" ]; then
        # dispositivos visibles aun no emparejados
        CAND=$(kdeconnect-cli -l --id-only 2>/dev/null | head -1)
        [ -z "$CAND" ] && { dunstify $TAG "${I_TEL}  Ningun movil visible" "Abre KDE Connect en el telefono, misma Wi-Fi"; exit 0; }
        kdeconnect-cli -d "$CAND" --pair >/dev/null 2>&1
        dunstify $TAG "${I_PAIR}  Solicitud enviada" "Acepta el emparejamiento en el movil"
    fi
    exit 0
fi

NOMBRE=$(kdeconnect-cli -a --name-only 2>/dev/null | head -1)
OPC=("${I_RING}  Hacer sonar el movil" "${I_CLIP}  Enviar portapapeles al movil" "${I_TEL}  Ver notificaciones del movil")
IDX=$(printf '%s\n' "${OPC[@]}" | rofi -dmenu -i -format i -p " ${I_TEL}  $NOMBRE " \
    -theme-str "listview { columns: 1; lines: 3; } element { orientation: horizontal; }")
case "$IDX" in
    0) kdeconnect-cli -d "$ID" --ring >/dev/null 2>&1 && dunstify $TAG "${I_RING}  Sonando..." ;;
    1) kdeconnect-cli -d "$ID" --send-clipboard >/dev/null 2>&1 && dunstify $TAG "${I_CLIP}  Portapapeles enviado" ;;
    2) N=$(kdeconnect-cli -d "$ID" --list-notifications 2>/dev/null | grep -v '^$' | head -8)
       dunstify $TAG "${I_TEL}  $NOMBRE" "${N:-(sin notificaciones)}" ;;
esac
