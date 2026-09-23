#!/bin/bash
# leer.sh — lee texto en voz alta (Piper + mpv) — Rice "Debian Crimson"
#
#   leer.sh "texto"     o  ... | leer.sh     empieza a leer
#   leer.sh pausa       pausa / reanuda DONDE IBA (super + shift + s)
#   leer.sh parar       corta del todo      (super + shift + x)
#   leer.sh atras       retrocede 10 s      (super + shift + z)
#   leer.sh adelante    adelanta 10 s
#   leer.sh estado      para polybar: hablando / en pausa / nada
#
# Como funciona: Piper (local, sin internet) sintetiza el texto TROCEADO
# por parrafos; el primer trozo se manda a mpv y los siguientes se le van
# añadiendo a la lista por su socket IPC. Asi empieza a hablar en ~1 s
# aunque la respuesta sea larga, y como quien reproduce es mpv se puede
# pausar y reanudar de verdad (no matar y volver a empezar).

PIPER=~/.local/opt/piper/piper
VOZ=~/.local/share/piper-voces/es_MX-claude-high.onnx
SOCK=/tmp/leer-mpv.sock
DIR=/tmp/leer-$UID
PID_GEN=$DIR/generador.pid

ipc() {   # manda una orden a mpv por el socket (sin socat: python3 basta)
    [ -S "$SOCK" ] || return 1
    python3 - "$@" <<'PY' 2>/dev/null
import socket, sys, json
s = socket.socket(socket.AF_UNIX); s.settimeout(1)
s.connect("/tmp/leer-mpv.sock")
s.send((json.dumps({"command": sys.argv[1:]}) + "\n").encode())
print(s.recv(4096).decode().strip())
PY
}

case "$1" in
    _append)   # uso interno: añadir un wav a la lista de mpv
        ipc loadfile "$2" append >/dev/null; exit 0 ;;
    pausa)
        ipc cycle pause >/dev/null && polybar-msg action voz exec >/dev/null 2>&1; exit 0 ;;
    parar)
        [ -f "$PID_GEN" ] && kill "$(cat "$PID_GEN")" 2>/dev/null
        ipc quit >/dev/null; rm -rf "$DIR"
        polybar-msg action voz exec >/dev/null 2>&1; exit 0 ;;
    atras)    ipc seek -10 >/dev/null; exit 0 ;;
    adelante) ipc seek 10  >/dev/null; exit 0 ;;
    estado)
        # nf-md-volume_high / nf-md-pause  (solo se ve si hay algo sonando)
        { pgrep -x mpv >/dev/null && [ -S "$SOCK" ]; } || exit 0
        if ipc get_property pause | grep -q '"data":true'; then
            printf '%%{F#45474e}\U000f03e4%%{F-}\n'
        else
            printf '%%{F#E8B04B}\U000f057e%%{F-}\n'
        fi
        exit 0 ;;
esac

command -v mpv >/dev/null || { dunstify -u critical "Voz: falta mpv"; exit 1; }
if [ ! -x "$PIPER" ] || [ ! -f "$VOZ" ]; then
    dunstify -u critical "Voz: falta piper o la voz" "Ver ~/.local/opt/piper y ~/.local/share/piper-voces"
    exit 1
fi

TEXTO="$*"; [ -z "$TEXTO" ] && TEXTO=$(cat)
[ -z "${TEXTO// /}" ] && exit 0

"$0" parar 2>/dev/null; sleep 0.2      # una lectura a la vez
mkdir -p "$DIR"

# Limpieza MINIMA: se quita solo la sintaxis de markdown (que se oiria como
# ruido: asteriscos, almohadillas, comillas de codigo) y las barras de las
# tablas pasan a comas para que suenen como pausas. No se quita contenido.
python3 - "$TEXTO" > "$DIR/fuente" <<'PY'
import re, sys
t = sys.argv[1]
t = re.sub(r'```[^\n]*\n(.*?)```', r'\1', t, flags=re.S)   # vallas de codigo
t = re.sub(r'[`*_#>]+', ' ', t)                            # marcas de markdown
t = re.sub(r'^\s*\|?\s*[-: |]+\s*\|?\s*$', '', t, flags=re.M)  # separadores de tabla
t = re.sub(r'\s*\|\s*', ', ', t)                           # celdas -> pausas
t = re.sub(r'\n{2,}', '\n\n', t)
print(t.strip())
PY

# trocear por parrafos, juntando hasta ~400 caracteres por trozo
python3 - "$DIR" <<'PY'
import sys, os, re
d = sys.argv[1]
texto = open(os.path.join(d, "fuente"), encoding="utf-8").read()
trozos, actual = [], ""
for parrafo in re.split(r'\n\s*\n|\n(?=[-•\d])', texto):
    parrafo = " ".join(parrafo.split())
    if not parrafo:
        continue
    if len(actual) + len(parrafo) > 400 and actual:
        trozos.append(actual); actual = parrafo
    else:
        actual = (actual + " " + parrafo).strip()
if actual:
    trozos.append(actual)
for i, tr in enumerate(trozos):
    open(os.path.join(d, "parte%03d.txt" % i), "w", encoding="utf-8").write(tr)
PY

(   # generador: sintetiza trozo a trozo y se los va pasando a mpv
    PRIMERO=1
    for f in "$DIR"/parte*.txt; do
        [ -e "$f" ] || break
        WAV="${f%.txt}.wav"
        "$PIPER" --model "$VOZ" --output_file "$WAV" < "$f" >/dev/null 2>&1 || continue
        if [ "$PRIMERO" = 1 ]; then
            # sin --idle: mpv se cierra solo al acabar la lista. Piper genera
            # 7x mas rapido de lo que se reproduce, asi que siempre va por
            # delante y nunca se queda sin trozos a medias.
            setsid mpv --no-video --really-quiet --input-ipc-server="$SOCK" \
                --keep-open=no "$WAV" >/dev/null 2>&1 < /dev/null &
            PRIMERO=0
            sleep 0.5
            polybar-msg action voz exec >/dev/null 2>&1
        else
            "$0" _append "$WAV"
        fi
    done
    # cuando mpv termina la lista, limpiar
    while pgrep -x mpv >/dev/null && [ -S "$SOCK" ]; do sleep 1; done
    rm -rf "$DIR"
    polybar-msg action voz exec >/dev/null 2>&1
) & echo $! > "$PID_GEN"
