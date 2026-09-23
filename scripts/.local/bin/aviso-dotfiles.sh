#!/bin/bash
# aviso-dotfiles.sh — avisa si ~/.dotfiles tiene cambios sin subir a GitHub
# Rice Debian Crimson. Lo llama bspwmrc al iniciar sesion (una vez).
#
# ~/.dotfiles ES el sistema (stow enlaza a el), asi que nunca se
# desactualiza respecto a la laptop. Lo que si puede quedarse atras es
# GitHub: solo se actualiza con commit + push. Este aviso lo recuerda.

REPO=~/.dotfiles
[ -d "$REPO/.git" ] || exit 0
sleep 8   # dejar que dunst y la red esten listos

ICON=$(printf '\U000f02a2')   # nf-md-git
MOD=$(git -C "$REPO" status --porcelain 2>/dev/null | wc -l)
# timeout: sin red (o con red lenta) git puede tardar minutos
timeout 20 git -C "$REPO" fetch -q 2>/dev/null
SIN_SUBIR=$(git -C "$REPO" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
SIN_BAJAR=$(git -C "$REPO" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)

MSG=""
[ "$MOD" -gt 0 ]       && MSG+="$MOD archivo(s) modificados sin commit\n"
[ "$SIN_SUBIR" -gt 0 ] && MSG+="$SIN_SUBIR commit(s) sin push\n"
[ "$SIN_BAJAR" -gt 0 ] && MSG+="$SIN_BAJAR commit(s) nuevos en GitHub (git pull)\n"
[ -n "$MSG" ] && dunstify -t 15000 -h string:x-dunst-stack-tag:dotfiles \
    "${ICON}  dotfiles: hay trabajo pendiente" "$(printf '%b' "$MSG")cd ~/.dotfiles && git status"
exit 0
