#!/bin/bash
# leer-respuesta.sh — lee en voz alta la ultima respuesta de Claude Code
# Rice "Debian Crimson"
#
# Lo llama el hook "Stop" de Claude Code (~/.claude/settings.json), que se
# dispara cada vez que Claude termina de responder. Por stdin llega un JSON
# con "transcript_path": el historial de la sesion en JSONL; de ahi se saca
# el ultimo mensaje del asistente y se manda a leer.sh.
#
# OJO (lo aprendimos a la mala): el hook salta ANTES de que Claude Code
# termine de escribir la respuesta en el transcript, asi que leerlo de
# inmediato devuelve la respuesta ANTERIOR. Por eso se espera a que el
# archivo deje de crecer. Y se guarda una huella de lo ultimo leido para
# no repetir si el hook salta dos veces (pasa con /clear o al compactar).
#
# Pausar/reanudar: super + shift + s     Cortar: super + shift + x
# Desactivarlo: /hooks dentro de Claude Code.

ENTRADA=$(cat)
TEXTO=$(python3 - "$ENTRADA" <<'PY'
import json, os, sys, time

try:
    datos = json.loads(sys.argv[1])
except Exception:
    sys.exit(0)
ruta = datos.get("transcript_path")
if not ruta or not os.path.exists(ruta):
    sys.exit(0)

# esperar a que el transcript se estabilice (max 6 s): dos medidas iguales
# separadas por medio segundo significan que ya se escribio todo
anterior, estables = -1, 0
for _ in range(12):
    try:
        actual = os.path.getsize(ruta)
    except OSError:
        break
    estables = estables + 1 if actual == anterior else 0
    if estables >= 2:
        break
    anterior = actual
    time.sleep(0.5)

ultimo = ""
try:
    with open(ruta, encoding="utf-8") as f:
        for linea in f:
            try:
                d = json.loads(linea)
            except Exception:
                continue
            if d.get("type") != "assistant":
                continue
            bloques = d.get("message", {}).get("content", [])
            texto = " ".join(
                b.get("text", "") for b in bloques
                if isinstance(b, dict) and b.get("type") == "text"
            ).strip()
            if texto:
                ultimo = texto
except OSError:
    sys.exit(0)

# no repetir lo ya leido
huella = os.path.expanduser("~/.cache/leer-respuesta.ultima")
import hashlib
h = hashlib.md5(ultimo.encode()).hexdigest()
try:
    if open(huella).read().strip() == h:
        sys.exit(0)
except OSError:
    pass
try:
    os.makedirs(os.path.dirname(huella), exist_ok=True)
    open(huella, "w").write(h)
except OSError:
    pass
print(ultimo)
PY
)
[ -z "${TEXTO// /}" ] && exit 0
~/.local/bin/leer.sh "$TEXTO"
