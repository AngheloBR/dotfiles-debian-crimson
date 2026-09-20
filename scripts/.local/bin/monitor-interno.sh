#!/bin/bash
# monitor-interno.sh — imprime el nombre del monitor principal
# Rice Debian Crimson. Lo usan bspwmrc, ajustar-monitores.sh y polybar.
#
# No se puede escribir "eDP" a fuego: en la laptop es eDP, en una VM es
# Virtual-1, en otro equipo eDP-1 o LVDS-1. Regla: el que xrandr marca
# como "primary"; si ninguno lo esta, el primero conectado.
xrandr --query | awk '/ connected primary/{print $1; exit}' | grep . || \
xrandr --query | awk '/ connected/{print $1; exit}'
