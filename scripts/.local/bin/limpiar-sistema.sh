#!/bin/bash
# limpiar-sistema.sh — limpieza mensual (Rice Debian Crimson), menu F9
# Se abre en una kitty flotante. Pide sudo para lo del sistema.
#
# Que limpia y por que es seguro:
#   apt autoremove --purge   paquetes que ya nadie necesita (dependencias huerfanas)
#   apt clean                .deb ya instalados guardados en /var/cache/apt
#   journalctl --vacuum      logs del sistema de mas de 2 semanas
#   ~/.cache/thumbnails      miniaturas de Thunar (se regeneran solas)
#   ~/.cache/pip, npm...     caches de gestores que se vuelven a bajar
#   papelera                 ~/.local/share/Trash
# NO toca: ~/.cache entero (ahi viven cosas como el lock con blur o el
# historial del portapapeles), ni nada de /home fuera de lo listado.

C=$'\e[38;2;215;10;83m'; D=$'\e[38;2;232;176;75m'; G=$'\e[38;2;69;71;78m'; R=$'\e[0m'
usado() { df --output=used -B1 / | tail -1; }

echo "${C}󰃢  Limpieza del sistema${R}"
echo "${G}────────────────────────────────────────${R}"
ANTES=$(usado)

echo "${D}▸ apt autoremove + clean${R}"
sudo apt-get autoremove --purge -y 2>&1 | grep -E '^(Removing|Eliminando|Desinstalando)' | sed 's/^/   /'
sudo apt-get clean

echo "${D}▸ logs del sistema (> 2 semanas)${R}"
sudo journalctl --vacuum-time=2weeks 2>&1 | grep -iE 'freed|liberad' | sed 's/^/   /'

echo "${D}▸ caches del usuario${R}"
for d in ~/.cache/thumbnails ~/.cache/pip ~/.cache/npm ~/.cache/yarn ~/.cache/mesa_shader_cache; do
    [ -d "$d" ] && { printf '   %s (%s)\n' "$d" "$(du -sh "$d" | cut -f1)"; rm -rf "$d"; }
done

echo "${D}▸ papelera${R}"
if [ -d ~/.local/share/Trash/files ]; then
    printf '   %s\n' "$(du -sh ~/.local/share/Trash 2>/dev/null | cut -f1)"
    rm -rf ~/.local/share/Trash/files/* ~/.local/share/Trash/info/* 2>/dev/null
fi

DESPUES=$(usado)
LIBERADO=$(( (ANTES - DESPUES) / 1024 / 1024 ))
echo "${G}────────────────────────────────────────${R}"
echo "${C}󰄬  Liberados ${LIBERADO} MB${R}  ${G}(libre ahora: $(df -h / | awk 'NR==2{print $4}'))${R}"
dunstify "$(printf '\U000f00c1')  Limpieza: ${LIBERADO} MB liberados"
echo; read -r -p "Enter para cerrar" _
