# AGENTS.md — Contexto para IAs (Claude Code, opencode, Codex...)

Este repo son los dotfiles del rice **"Debian Crimson"**: Debian 13 (trixie)
+ bspwm + GNU stow, en español y minimalista. Léelo TODO antes de tocar nada.

## Cómo está montado

- Los archivos ORIGINALES viven aquí; `~/.config/*`, `~/.zshrc`, `~/.local/bin`
  son ENLACES SIMBÓLICOS a este repo (GNU stow). **Cualquier cambio aquí
  afecta el sistema en vivo inmediatamente.** Y `~/.dotfiles` NO se
  borra ni se mueve: es el sistema.
- Paquetes: bspwm sxhkd polybar kitty rofi dunst picom picom-vm gtk thunar
  gammastep xdg zathura fastfetch zsh git nvim(LazyVim) scripts wallpapers
- Teclado: `latam`. Shell: zsh + p10k. Terminal: kitty. Editor: LazyVim
  (nvim 0.12 en `~/.local/opt`, NO el 0.10 de Debian).

## Reglas de la casa (no negociables)

1. TODO vive en la laptop (eDP): barra completa con 8 escritorios,
   power menu, bluetooth, ajustes (F9), etc.
2. El HDMI externo, si existe, SOLO muestra wallpaper: un escritorio
   vacío y SIN barra. `ajustar-monitores.sh` se encarga de todo.
3. Paleta: fondo `#0f0f12`, carmesí `#D70A53` (foco/selección),
   dorado `#E8B04B` (iconos/reloj). Nada de azules ni temas ajenos.
4. Minimalismo: si un paquete/config no se usa, no entra al repo.

## Cómo probar los cambios

- sxhkd → `pkill -USR1 -x sxhkd` (o super+Escape)
- polybar → `pkill -x polybar` y relanzar `polybar main` (solo en eDP)
- monitores → `~/.local/bin/ajustar-monitores.sh`
- bspwmrc → NO ejecutar `bspc wm -r` a lo loco con ventanas abiertas
- iconos Nerd Font: generan pérdida al copiar; usar escapes `\uXXXX`
  con printf/python dentro de scripts (lección de la guía §7)

## Antes de commitear

`./comprobar.sh` (shellcheck, configs, paquetes). Debe decir TODO OK.

## Git

- Commits en ESPAÑOL, descriptivos, y push directo (gh autenticado).
- NUNCA commitear binarios o symlinks locales (ver .gitignore:
  nvim, claude).

## Filosofía del dueño (anghelo)

Debian por estabilidad. Aprende con cada cambio: **explica el porqué**
de todo, en español, sin asumir conocimiento previo. Si algo se rompe,
se arregla con `git checkout` y ya. Guía histórica completa:
`GUIA-RICE-DEBIAN-BSPWM.txt`. Instalación limpia: ver `README.md`.
