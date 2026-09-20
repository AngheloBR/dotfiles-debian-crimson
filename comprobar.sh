#!/bin/bash
# comprobar.sh — valida el repo antes de commitear / reinstalar
# Rice "Debian Crimson". Uso: ./comprobar.sh
#   1. shellcheck + bash -n de todos los scripts
#   2. sintaxis de las configs (polybar, rofi, dunst, kitty, picom, sxhkd, json, xml, zsh)
#   3. que cada paquete stow del repo este en instalador.sh (y viceversa)
#   4. que cada paquete apt del instalador exista en los repos de Debian
#   5. binarios usados por los scripts que no aporte ningun paquete del instalador
# shellcheck disable=SC2015,SC2001,SC1003
# (SC2015: "prueba && ok || ko" es intencional, ok nunca falla)
cd "$(dirname "$0")" || exit 1
FALLOS=0
ko() { echo "  ✗ $*"; FALLOS=$((FALLOS+1)); }
ok() { echo "  ✓ $*"; }

echo "1. scripts"
SCRIPTS=(scripts/.local/bin/*.sh bspwm/.config/bspwm/bspwmrc instalador.sh instalar-paquetes.sh wallpapers/generar-fondos.sh comprobar.sh sistema/usr/local/sbin/firewall-perfil sistema/etc/NetworkManager/dispatcher.d/*)
for s in "${SCRIPTS[@]}"; do bash -n "$s" 2>/dev/null || ko "sintaxis: $s"; done
if command -v shellcheck >/dev/null; then
    OUT=$(shellcheck -f gcc "${SCRIPTS[@]}" 2>&1); [ -z "$OUT" ] && ok "shellcheck limpio" || { ko "shellcheck:"; echo "$OUT" | sed 's/^/      /'; }
fi

echo "2. configs"
polybar -c polybar/.config/polybar/config.ini --dump=modules-right main >/dev/null 2>&1 && ok polybar || ko polybar
rofi -config rofi/.config/rofi/config.rasi -dump-config >/dev/null 2>&1 && ok rofi || ko rofi
dunst -conf dunst/.config/dunst/dunstrc -print 2>&1 | grep -qiE 'error|warn' && ko dunst || ok dunst
kitty --config kitty/.config/kitty/kitty.conf --debug-config 2>&1 | grep -qi error && ko kitty || ok kitty
for c in picom picom-vm; do picom --config $c/.config/picom/picom.conf --diagnostics 2>&1 | grep -qiE 'error|invalid' && ko $c || ok $c; done
timeout 1 sxhkd -c sxhkd/.config/sxhkd/sxhkdrc 2>&1 | grep -qi error && ko sxhkd || ok sxhkd
python3 -c "import json,re;s=open('fastfetch/.config/fastfetch/config.jsonc').read();json.loads(re.sub(r'^\s*//.*$','',s,flags=re.M))" 2>/dev/null && ok fastfetch || ko fastfetch
for x in thunar/.config/Thunar/uca.xml sistema/libvirt/red-default.xml; do python3 -c "import xml.dom.minidom as m;m.parse('$x')" 2>/dev/null && ok "$x" || ko "$x"; done
zsh -n zsh/.zshrc 2>/dev/null && ok zshrc || ko zshrc
/usr/sbin/visudo -cf sistema/etc/sudoers.d/firewall-perfil >/dev/null 2>&1 && ok sudoers || ko sudoers

echo "3. paquetes stow vs instalador.sh"
LISTA=$(grep -oE '^stow .*' instalador.sh | sed 's/^stow //; s/ *-[A-Za-z]* */ /g')
for d in */; do d=${d%/}; case $d in docs|sistema|wallpapers|nvim|picom|picom-vm) continue;; esac
    echo " $LISTA " | grep -q " $d " && ok "$d" || ko "falta en instalador.sh: $d"; done
for s in $LISTA; do [ -d "$s" ] || ko "instalador.sh cita paquete inexistente: $s"; done

echo "4. paquetes apt del instalador (existen en Debian)"
# solo las lineas del "apt install -y" y sus continuaciones con barra invertida
PKGS=$(awk '/apt install -y/{p=1} p{print; if ($0 !~ /\\$/) p=0}' instalar-paquetes.sh | tr -d '\\' | tr ' ' '\n' | grep -E '^[a-z0-9.+-]+$' | grep -vE '^(sudo|apt|install|-y)$' | sort -u)
N=0; for p in $PKGS; do N=$((N+1)); apt-cache policy "$p" 2>/dev/null | grep -q 'Candidat[oe]: [^(]' || ko "no existe en los repos: $p"; done; ok "$N paquetes comprobados"

echo "5. binarios de los scripts sin paquete en el instalador"
BINS=$(cat scripts/.local/bin/*.sh bspwm/.config/bspwm/bspwmrc sxhkd/.config/sxhkd/sxhkdrc polybar/.config/polybar/config.ini thunar/.config/Thunar/uca.xml sistema/usr/local/sbin/firewall-perfil xdg/.local/share/applications/*.desktop \
  | grep -vE '^\s*#' | grep -oE '(^|[ (|;`&=]|-e |exec = |Exec=)[a-z][a-z0-9_.-]{2,}' | sed -E 's/^(.*[ (|;`&=]|-e |exec = |Exec=)//' | sort -u)
# palabras que salen en comentarios o que Debian trae de serie (sudo llega
# con el instalador si la contraseña de root se deja vacia; firefox es un
# alias de firefox-esr)
IGNORAR=" sudo firefox bluetooth cancel print last script reset "
declare -A V; for b in $BINS; do
    case "$IGNORAR" in *" $b "*) continue;; esac
    P=$(command -v -- "$b" 2>/dev/null) || continue
    case "$P" in /usr/bin/*|/usr/sbin/*|/bin/*|/sbin/*) ;; *) continue;; esac
    PK=$(dpkg -S "$P" 2>/dev/null | head -1 | cut -d: -f1); [ -z "$PK" ] || [ -n "${V[$PK]}" ] && continue; V[$PK]=1
    echo "$PKGS" | grep -qx "$PK" && continue
    PRIO=$(apt-cache show "$PK" 2>/dev/null | grep -m1 '^Priority:' | awk '{print $2}')
    case "$PRIO" in required|important|standard) ;; *) ko "$b -> $PK no esta en el instalador";; esac
done; ok "binarios revisados"

echo; [ $FALLOS -eq 0 ] && echo "TODO OK" || { echo "$FALLOS problema(s)"; exit 1; }
