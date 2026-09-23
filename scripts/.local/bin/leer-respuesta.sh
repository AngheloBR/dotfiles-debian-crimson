#!/bin/bash
# leer-respuesta.sh — lee en voz alta la ultima respuesta de Claude Code
# Rice "Debian Crimson"
#
# Lo llama el hook "Stop" de Claude Code (~/.claude/settings.json), que se
# dispara cada vez que Claude termina de responder. Por stdin llega un JSON
# con "transcript_path": el historial de la sesion en formato JSONL. De ahi
# se saca el ultimo mensaje del asistente y se manda a leer.sh.
#
# Pausar/reanudar: super + shift + s     Cortar: super + shift + x
# Para desactivarlo: quitar el hook con /hooks en Claude Code.

ENTRADA=$(cat)
TEXTO=$(python3 - "$ENTRADA" <<'PY'
import json, sys
try:
    datos = json.loads(sys.argv[1])
except Exception:
    sys.exit(0)
ruta = datos.get("transcript_path")
if not ruta:
    sys.exit(0)
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
print(ultimo)
PY
)
[ -z "${TEXTO// /}" ] && exit 0
~/.local/bin/leer.sh "$TEXTO"
