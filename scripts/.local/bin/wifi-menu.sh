#!/bin/bash
# wifi-menu.sh — conectarse a redes Wi-Fi desde rofi (Rice Debian Crimson)
# Lo abre el click en el icono de red de polybar.
#
# Cada red sale con: icono de señal (4 niveles) · nombre · candado si
# tiene clave · estrella si ya esta guardada · check si es la activa.
#   - red guardada     -> conecta directo (nmcli ya tiene la clave)
#   - red nueva c/clave -> pide la contraseña en rofi (oculta)
#   - red activa       -> submenu: desconectar / olvidar
# Arriba del todo: buscar de nuevo y encender/apagar el Wi-Fi.
#
# Truco: rofi devuelve el NUMERO de linea (-format i), no el texto.
# Asi da igual que el nombre de la red tenga espacios o simbolos raros.

I_WIFI=$(printf '\U000f0928')      # nf-md-wifi_strength_4
I_S1=$(printf '\U000f091f'); I_S2=$(printf '\U000f0922')
I_S3=$(printf '\U000f0925'); I_S4=$(printf '\U000f0928')
I_OFF=$(printf '\U000f092e')       # nf-md-wifi_strength_off
I_LOCK=$(printf '\U000f033e')      # nf-md-lock
I_STAR=$(printf '\U000f04ce')      # nf-md-star (guardada)
I_OK=$(printf '\U000f05e0')        # nf-md-check_circle (activa)
I_RESCAN=$(printf '\U000f0453')    # nf-md-reload
I_KEY=$(printf '\U000f0306')       # nf-md-key
I_DEL=$(printf '\U000f01b4')       # nf-md-delete
I_DISC=$(printf '\U000f0319')      # nf-md-lan_disconnect

TAG="-h string:x-dunst-stack-tag:wifi"

menu() {   # menu "prompt" "lineas" <<< opciones  -> imprime el indice elegido
    rofi -dmenu -i -format i -p " $1 " \
        -theme-str "listview { columns: 1; lines: $2; } element { orientation: horizontal; }"
}

icono_senal() {   # 0-100 -> icono de barras
    if   [ "$1" -ge 75 ]; then echo "$I_S4"
    elif [ "$1" -ge 50 ]; then echo "$I_S3"
    elif [ "$1" -ge 25 ]; then echo "$I_S2"
    else echo "$I_S1"; fi
}

# ── Wi-Fi apagado: solo ofrecer encenderlo ──
if ! LANG=C nmcli radio wifi | grep -q enabled; then
    IDX=$(printf '%s  Encender Wi-Fi' "$I_WIFI" | menu "${I_OFF}  Wi-Fi apagado" 1)
    [ "$IDX" = "0" ] && ~/.local/bin/red-wifi.sh toggle
    exit 0
fi

# ── escanear (bloquea 2-4 s: avisar) ──
dunstify $TAG -t 3000 "${I_RESCAN}  Buscando redes Wi-Fi..."
GUARDADAS=$(nmcli -t -f NAME,TYPE con show | awk -F: '$2=="802-11-wireless"{print $1}')

SSIDS=(); SEGS=(); ACTIVA=""; LINEAS=""
while IFS=: read -r enuso ssid senal seguridad; do
    [ -z "$ssid" ] && continue                          # redes ocultas
    for s in "${SSIDS[@]}"; do [ "$s" = "$ssid" ] && continue 2; done   # sin repetidos
    SSIDS+=("$ssid"); SEGS+=("$seguridad")
    marca=""
    [ "$enuso" = "*" ] && { ACTIVA="$ssid"; marca=" ${I_OK}"; }
    grep -qxF "$ssid" <<< "$GUARDADAS" && [ "$enuso" != "*" ] && marca=" ${I_STAR}"
    cand=""; [ -n "$seguridad" ] && cand=" ${I_LOCK}"
    LINEAS+="$(icono_senal "$senal")  ${ssid}${cand}${marca}"$'\n'
done < <(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan yes 2>/dev/null)

# 2 opciones fijas arriba + las redes (indices desplazados 2)
N=${#SSIDS[@]}; LINEAS_MENU=$((N + 2)); [ $LINEAS_MENU -gt 12 ] && LINEAS_MENU=12
IDX=$(printf '%s  Buscar de nuevo\n%s  Apagar Wi-Fi\n%s' "$I_RESCAN" "$I_OFF" "$LINEAS" | \
      menu "${I_WIFI}  Wi-Fi" "$LINEAS_MENU")
[ -z "$IDX" ] && exit 0

case "$IDX" in
    0) exec "$0" ;;
    1) ~/.local/bin/red-wifi.sh toggle; exit 0 ;;
esac

SSID="${SSIDS[$((IDX - 2))]}"
SEG="${SEGS[$((IDX - 2))]}"

# ── la activa: desconectar u olvidar ──
if [ "$SSID" = "$ACTIVA" ]; then
    SUB=$(printf '%s  Desconectar\n%s  Olvidar esta red' "$I_DISC" "$I_DEL" | menu "${I_OK}  $SSID" 2)
    case "$SUB" in
        0) nmcli con down id "$SSID" >/dev/null 2>&1 && dunstify $TAG "${I_DISC}  Desconectado de $SSID" ;;
        1) nmcli con delete id "$SSID" >/dev/null 2>&1 && dunstify $TAG "${I_DEL}  Red olvidada: $SSID" ;;
    esac
    exit 0
fi

# ── guardada: conectar directo ──
if grep -qxF "$SSID" <<< "$GUARDADAS"; then
    dunstify $TAG "${I_WIFI}  Conectando a $SSID..."
    if nmcli con up id "$SSID" >/dev/null 2>&1; then
        dunstify $TAG "${I_OK}  Conectado a $SSID"
    else
        dunstify -u critical $TAG "${I_OFF}  No se pudo conectar a $SSID"
    fi
    exit 0
fi

# ── nueva: pedir clave si hace falta ──
if [ -n "$SEG" ]; then
    CLAVE=$(rofi -dmenu -password -p " ${I_KEY}  Clave de $SSID " \
            -theme-str "listview { enabled: false; }")
    [ -z "$CLAVE" ] && exit 0
    dunstify $TAG "${I_WIFI}  Conectando a $SSID..."
    if nmcli dev wifi connect "$SSID" password "$CLAVE" >/dev/null 2>&1; then
        dunstify $TAG "${I_OK}  Conectado a $SSID (guardada)"
    else
        # nmcli deja creada la conexion aunque falle: borrarla para
        # que no aparezca como "guardada" con la clave mala
        nmcli con delete id "$SSID" >/dev/null 2>&1
        dunstify -u critical $TAG "${I_OFF}  Clave incorrecta o sin señal: $SSID"
    fi
else
    dunstify $TAG "${I_WIFI}  Conectando a $SSID (abierta)..."
    if nmcli dev wifi connect "$SSID" >/dev/null 2>&1; then
        dunstify $TAG "${I_OK}  Conectado a $SSID"
    else
        nmcli con delete id "$SSID" >/dev/null 2>&1
        dunstify -u critical $TAG "${I_OFF}  No se pudo conectar a $SSID"
    fi
fi
