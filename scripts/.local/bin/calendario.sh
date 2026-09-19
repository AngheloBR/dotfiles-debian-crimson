#!/bin/bash
# calendario.sh — calendario de 3 meses al hacer click en la fecha
# Rice "Debian Crimson"
#
# El comando 'cal' no viene en la instalacion minimal de Debian
# (viene del paquete ncal). Usamos python3 (siempre presente) con
# nombres en espanol FIJOS (independiente de los locales generados)
# y el dia de hoy resaltado con el carmesi del rice.

python3 <<'PYEOF'
import calendar, datetime, re

hoy = datetime.date.today()
ANCHO = 20

MESES = ["enero", "febrero", "marzo", "abril", "mayo", "junio",
         "julio", "agosto", "septiembre", "octubre", "noviembre",
         "diciembre"]
DIAS = "lu ma mi ju vi sá do"

cal = calendar.Calendar(firstweekday=0)  # semana desde lunes

def ajustar(ano, mes, delta):
    total = ano * 12 + (mes - 1) + delta
    return total // 12, total % 12 + 1

def bloque_mes(ano, mes, es_actual):
    lineas = []
    titulo = f"{MESES[mes - 1]} {ano}".capitalize()
    lineas.append(titulo.center(ANCHO))
    lineas.append(DIAS)
    for semana in cal.monthdayscalendar(ano, mes):
        fila = " ".join(f"{d:2d}" if d else "  " for d in semana)
        if es_actual:
            patron = r'(?<!\d)%d(?!\d)' % hoy.day
            repl = '\033[38;2;15;15;18;48;2;215;10;83m%d\033[0m' % hoy.day
            fila = re.sub(patron, repl, fila, count=1)
        lineas.append(fila)
    return lineas

bloques = []
for delta in (-1, 0, 1):
    y, m = ajustar(hoy.year, hoy.month, delta)
    bloques.append(bloque_mes(y, m, delta == 0))

alto = max(len(b) for b in bloques)
salida = []
for i in range(alto):
    fila = "   ".join((b[i] if i < len(b) else "").ljust(ANCHO) for b in bloques)
    salida.append(fila.rstrip())
print("\n".join(salida))
PYEOF

echo
printf "Enter para cerrar: "
read x
