#!/bin/bash
# actualizaciones.sh — paquetes por actualizar, para polybar (Rice Debian Crimson)
#   sin args  -> icono + numero (nada si no hay: modulo oculto)
#   instalar  -> abre kitty con "sudo apt upgrade" (click en el icono)
#
# "apt-get -s upgrade" SIMULA la actualizacion: no necesita root y no
# toca nada, solo cuenta que instalaria. Cuenta contra las listas locales,
# que refresca el timer apt-daily del sistema (hace falta
# APT::Periodic::Update-Package-Lists "1" en /etc/apt/apt.conf.d/).

ICON=$(printf '\U000f06b0')   # nf-md-package_variant (caja)

if [ "$1" = "instalar" ]; then
    kitty --class actualizar -e sh -c 'sudo apt update && sudo apt upgrade; echo; read -p "Enter para cerrar" x' &
    exit 0
fi

N=$(apt-get -s upgrade 2>/dev/null | grep -c '^Inst')
[ "$N" -eq 0 ] && exit 0
echo "%{F#E8B04B}${ICON}%{F-} $N"
