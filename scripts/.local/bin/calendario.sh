#!/bin/bash
# calendario.sh — se abre al hacer click en la fecha de la polybar
# (la config de polybar no permite ; en los comandos de click,
#  por eso el calendario vive en su propio script)

cal -3
echo
printf "Enter para cerrar: "
read x
