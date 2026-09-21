#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Instalador de dotfiles — Rice "Debian Crimson"
#  Uso: ./instalador.sh   (desde la carpeta del repo clonado)
# ═══════════════════════════════════════════════════════
set -e
cd "$(dirname "$0")"

# -R (restow): re-enlaza aunque ya estuviera hecho. Necesario tras un
# "git pull" que traiga scripts NUEVOS: ~/.local/bin es una carpeta real
# (el instalador mete ahi el symlink de nvim antes que stow), asi que
# stow enlaza archivo por archivo y los nuevos no aparecen solos.
echo "==> Enlazando configs con stow..."

# Paquetes comunes (siempre)
stow -R bspwm sxhkd polybar kitty rofi dunst gtk thunar zsh git scripts gammastep xdg zathura fastfetch

# Neovim (LazyVim) — solo si no hay ya una config del usuario
if [ -e ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
  echo "   AVISO: ~/.config/nvim existe y no es symlink."
  echo "   No se toca. Respalda y borra manual para stow nvim."
else
  stow -R nvim
fi

echo "==> Detectando entorno para picom..."
if systemd-detect-virt -q; then
    echo "   VM detectada    -> picom ligero (xrender, sin blur)"
    stow -D picom 2>/dev/null || true
    stow -R picom-vm
else
    echo "   Hardware real   -> picom completo (glx + blur)"
    stow -D picom-vm 2>/dev/null || true
    stow -R picom
fi

echo ""
echo "Instalacion completa."
echo "Siguiente paso: cierra sesion de la TTY actual y vuelve a entrar"
echo "(o reinicia). Todo queda enlace-simbolico a este repo."
