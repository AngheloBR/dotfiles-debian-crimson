#!/bin/bash
# ═══════════════════════════════════════════════════
#  bloquear.sh — Lock con blur del wallpaper (Rice Crimson)
#  Requiere: i3lock. Opcional: imagemagick (para blur).
#  Sin imagemagick: bloquea con color solido (fallback).
# ═══════════════════════════════════════════════════

WALLPAPER=$(grep -oP '(?<=--bg-scale ).*?(?= &)' ~/.config/bspwm/bspwmrc | head -1)
WALLPAPER="${WALLPAPER/#\~/$HOME}"
CACHE=~/.cache/lockscreen.png
HASH_FILE=~/.cache/lockscreen.md5

if command -v magick >/dev/null && [ -f "$WALLPAPER" ]; then
    mkdir -p ~/.cache
    HNEW=$(md5sum "$WALLPAPER" | cut -d' ' -f1)
    HOLD=$(cat "$HASH_FILE" 2>/dev/null)
    if [ "$HNEW" != "$HOLD" ] || [ ! -f "$CACHE" ]; then
        magick "$WALLPAPER" -resize 1920x1080^ -gravity center \
            -extent 1920x1080 -blur 0x8 "$CACHE"
        echo "$HNEW" > "$HASH_FILE"
    fi
    i3lock -i "$CACHE"
else
    # Fallback: negro profundo del rice (#0f0f12)
    i3lock -c 0f0f12
fi
