#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Instalador de dotfiles — Rice "Debian Crimson"
#  Uso: ./instalador.sh   (desde la carpeta del repo clonado)
# ═══════════════════════════════════════════════════════
set -e
cd "$(dirname "$0")"

echo "==> Enlazando configs con stow..."

# Paquetes comunes (siempre)
stow bspwm sxhkd polybar kitty rofi dunst gtk zsh scripts gammastep xdg

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
    stow picom-vm
else
    echo "   Hardware real   -> picom completo (glx + blur)"
    stow -D picom-vm 2>/dev/null || true
    stow picom
fi

echo ""
echo "Instalacion completa."
echo "Siguiente paso: cierra sesion de la TTY actual y vuelve a entrar"
echo "(o reinicia). Todo queda enlace-simbolico a este repo."
