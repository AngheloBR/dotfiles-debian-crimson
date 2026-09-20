#!/bin/bash
# generar-fondos.sh — fabrica los fondos del Rice "Debian Crimson"
# con ImageMagick (magick). Todos 1920x1080 y con la paleta de la casa:
#   fondo #0f0f12, carmesi #D70A53, dorado #E8B04B, gris #2b2b2e
#
# Ejecutar desde esta carpeta: ./generar-fondos.sh
# (fondo.png, el original, no se toca)

set -e
cd "$(dirname "$0")"
W=1920; H=1080
FUENTE=~/.local/share/fonts/JetBrainsMonoNerd/JetBrainsMonoNerdFont-Regular.ttf
DEBIAN=$(printf '')          # nf-linux-debian

# ── 1. debian.png: logo Debian gigante en carmesi apagado, abajo a la derecha
#    (el glifo sale de la Nerd Font, no hace falta ningun SVG)
magick -size ${W}x${H} xc:'#0f0f12' \
    \( -size ${W}x${H} radial-gradient:'#2a0a14-#0f0f12' -gravity center -extent ${W}x${H} \) \
    -compose lighten -composite \
    \( -size ${W}x${H} xc:none -font "$FUENTE" -pointsize 900 -fill '#6e0a2c' \
       -gravity southeast -annotate +40-140 "$DEBIAN" \
       -blur 0x30 -channel A -evaluate multiply 0.45 +channel \) \
    -compose over -composite \
    -font "$FUENTE" -pointsize 900 -fill '#6e0a2c' \
    -gravity southeast -annotate +40-140 "$DEBIAN" \
    debian.png

# ── 2. lineas.png: tres diagonales finas (2 carmesi + 1 dorada) con brillo bajo
magick -size ${W}x${H} xc:'#0f0f12' \
    \( -size ${W}x${H} radial-gradient:'#22090f-#0f0f12' \) -compose lighten -composite \
    -stroke '#D70A53' -strokewidth 2 -draw "line 0,880 1920,180" \
    -stroke '#D70A53' -strokewidth 1 -fill none -draw "line 0,1000 1920,300" \
    -stroke '#E8B04B' -strokewidth 1 -draw "line 300,1080 1920,480" \
    lineas.png

# ── 3. puntos.png: rejilla de puntos dorados muy tenues + brillo carmesi abajo-izq
magick -size 40x40 xc:none -fill '#E8B04B' -draw "circle 20,20 20,22.2" \
    -channel A -evaluate multiply 0.30 +channel miff:- | \
magick -size ${W}x${H} xc:'#0f0f12' \
    \( -size ${W}x${H} radial-gradient:'#3a0d1c-#0f0f12' -gravity southwest -extent ${W}x${H} \) \
    -compose lighten -composite \
    \( -size ${W}x${H} tile:- \) -compose over -composite \
    puntos.png

# ── 4. horizonte.png: banda carmesi que se funde en negro, con linea dorada
#    de "horizonte" a 2/3 de altura
magick -size ${W}x${H} radial-gradient:'#1c1216-#0f0f12' \
    \( -size ${W}x360 gradient:'#0f0f12-#2e0916' \) -gravity south -composite \
    -stroke '#E8B04B' -strokewidth 1 -draw "line 0,720 1920,720" \
    -stroke '#D70A53' -strokewidth 3 -draw "line 0,722 1920,722" \
    \( +clone -blur 0x12 \) -compose screen -composite \
    horizonte.png

# quitar metadatos y comprimir
for f in debian lineas puntos horizonte; do
    magick "$f.png" -strip -define png:compression-level=9 "$f.png"
done
echo "fondos generados:"; ls -la ./*.png
