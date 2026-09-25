# CONTEXTO.md — memoria del proyecto "Debian Crimson"

> **Para la IA que lea esto**: este archivo es el contexto completo del rice.
> Léelo entero junto a `AGENTS.md` antes de tocar nada. Recoge lo que se
> construyó, **por qué** se decidió cada cosa, lo que ya se descartó (no
> volver a proponerlo) y lo que queda pendiente.
>
> **Para anghelo**: este archivo sobrevive a una instalación limpia porque
> vive en el repo. Tras reinstalar, clona el repo y pídele a la IA que lo lea.
>
> Última actualización: 2026-09-25 · commit `e7feed3` · 68 commits

---

## 1. Quién es el dueño

- **anghelo**, Perú (zona horaria America/Lima, locale `es_PE.UTF-8`).
- Estudia/trabaja en **redes y seguridad informática**. Usará GNS3, Wireshark,
  nmap, AnyDesk, RustDesk, OBS, virt-manager/KVM, LXD, Waydroid.
- Viene de Fedora; eligió **Debian por estabilidad** (cansado de
  actualizaciones constantes).
- **Quiere entender lo que hace**: explicar el porqué de cada cambio, en
  español, sin asumir conocimiento previo. Aprende con cada commit.
- Prefiere que se le pregunte antes de operaciones destructivas, pero espera
  que las decisiones rutinarias se tomen sin consultar.

## 2. Hardware

| | |
|---|---|
| Equipo | Lenovo IdeaPad 1 15ALC7 |
| CPU | AMD Ryzen 7 5700U (8c/16t) |
| GPU | AMD Lucienne (integrada, driver amdgpu) — **sin NVIDIA**, Wayland iría bien |
| RAM | 13 GB |
| Disco | NVMe 954 GB (ver §8: Fedora ocupa 758 GB sin usar) |
| Pantalla | eDP 1920x1080, 15" |
| Monitor externo | HDMI-A-0 1920x1080 (opcional) |
| Sensores | batería `BAT0`, adaptador `ADP0`, temperatura `k10temp`, Wi-Fi `wlp2s0` |
| Teclado | latam. Teclas propias: F4 mic, F8 avión, F9 ajustes, F10 candado |

## 3. Qué es este repo

Dotfiles del rice **"Debian Crimson"**: Debian 13 (trixie) + X11 + bspwm,
en español, minimalista, gestionado con **GNU stow**.

- 101 archivos, 16 paquetes stow, 32 scripts, 82 paquetes apt en el instalador.
- `~/.config/*`, `~/.zshrc`, `~/.local/bin` son **enlaces** a este repo:
  editar aquí cambia el sistema en vivo. **`~/.dotfiles` no se borra: es el sistema.**
- Repo **privado** en `github.com/AngheloBR/dotfiles-debian-crimson`.
  Para clonar hace falta `gh auth login` primero.

### Paleta (regla no negociable)
fondo `#0f0f12` · carmesí `#D70A53` (foco/selección) · dorado `#E8B04B`
(iconos/reloj) · gris borde `#2b2b2e` · apagado `#45474e`. **Nada de azules.**

## 4. Qué está construido

**Escritorio**: bspwm (8 escritorios con iconos Nerd Font, foco sigue al ratón,
`single_monocle`), sxhkd (47 atajos), picom (glx+blur; `picom-vm` para VMs),
dunst, lightdm con greeter personalizado (usuario preseleccionado, cuadro a la
izquierda), rofi, kitty, LazyVim (nvim 0.12 en `~/.local/opt`), zsh+p10k+fzf.

**Barra (polybar, 20 módulos)**: logo, escritorios, voz, música, fecha,
bandeja del sistema, no-molestar, actualizaciones, firewall, VPN, Wi-Fi,
bluetooth, temperatura, CPU, memoria, batería, volumen, micrófono, luz
nocturna, power. Los módulos "condicionales" se ocultan solos cuando no aplican.

**Menú F9 (28 opciones)**: Wi-Fi, bluetooth, VPN, firewall, audio, impresoras,
escáner, expulsar USB, brillo, luz nocturna, fondo, monitores, limpiar
pantalla, capturas (ventana/región/pantalla), OCR, color, iconos Nerd Font,
no molestar, leer portapapeles, actualizar, limpiar sistema, chuleta, editar
dotfiles, recargas.

**Automatismos**: candado al suspender y a los 10 min (xss-lock, con blur y
candado dibujado; no bloquea si hay vídeo sonando), aviso de batería 20%/10%,
aviso de CPU > 90 °C, HDMI automático por evento del kernel (udev),
auto-montaje de USB (udiskie), luz nocturna (gammastep), aviso si el repo
tiene cambios sin subir, historial de portapapeles.

**Seguridad**: firewall nftables con **dos perfiles** (privada/pública) que se
eligen solos según la red Wi-Fi; VMs y contenedores (KVM, LXD, Docker, Podman,
Waydroid) tienen red en ambos. Modo `apagar` de emergencia.

**Voz**: Piper local (voz es_MX) lee las respuestas de Claude Code mediante un
hook `Stop`; mpv reproduce y permite pausar/reanudar donde iba.

## 5. Decisiones y su porqué (no deshacer sin motivo)

| Decisión | Por qué |
|---|---|
| **stow, no `cp`** | una sola copia: editar la config *es* editar el repo, nunca se desactualiza |
| **Nada de nombres de hardware a fuego** | `eDP`/`HDMI-A-0`/`BAT0`/`k10temp` se detectan; lo descubrió la prueba en VM (allí el monitor es `Virtual-1`) |
| **Iconos Material Design (U+F0xxx)** | los del BMP (Font Awesome) se pierden al copiar; en scripts van como `printf '\U000fXXXX'` |
| **Módulos internos de polybar** donde se puede | fecha y volumen sin scripts ni polling (el volumen va por eventos de pipewire) |
| **`polybar-msg cmd restart`**, no `pkill` | IPC nativo, sin sleeps |
| **Un `comprobar.sh`** | valida shellcheck, configs, paquetes stow y apt antes de cada commit |
| **Duplicación de iconos/colores entre scripts: se acepta** | una librería común haría que ningún script se entienda suelto; se valoró y se descartó |
| **X11, no Wayland** (por ahora) | AnyDesk es solo X11 y RustDesk va parcial: el control remoto entrante es justo lo que Wayland restringe por diseño |
| **bspwm, no un DE** | ya tiene todo lo que da un DE (udiskie, tlp, dunst, xss-lock, CUPS, F9), pieza a pieza y entendiendo cada una |
| **Firefox del repo de Mozilla** | Debian solo trae ESR |
| **LXD para sandbox, no KVM** | comparte kernel: 100% de CPU, arranca en 1 s |

## 6. Descartado explícitamente (no volver a proponer)

Calendario en la barra · terminal desplegable · apps fijadas a escritorios ·
toggle de gaps · listar ventanas con rofi (`super+shift+Tab` no dispara con
teclado latam) · disco en la barra · indicador de Caps Lock (el teclado se
ilumina) · vatios de consumo en la barra · KDE Connect · grabación con ffmpeg
(usa OBS) · repo charm.sh.

## 7. Pendientes reales

1. **Respaldo de `~`** a disco externo — aplazado por el dueño. Es el único
   hueco de verdad: el rice está en GitHub, sus datos no. **Se vuelve
   obligatorio antes de tocar particiones** (§8).
2. **Cifrado de disco (LUKS)** — solo se puede en una instalación limpia.
3. **Reglas de bspwm para GNS3 / virt-manager / Wireshark / AnyDesk** — hacerlo
   cuando se instalen, no antes (regla 4).
4. **Guardar y restaurar disposiciones de ventanas** (`bspc wm -d` / `-l`) para
   laboratorios de redes — idea aceptada, sin implementar.
5. **Probar Wayland en la VM** (`debian13`, snapshot `crimson-limpio`) — como
   aprendizaje, no para la laptop.

## 8. Situación del disco (en curso al cerrar este contexto)

```
nvme0n1 954 GB
├─p1  600 MB  vfat   /boot/efi
├─p2    2 GB  ext4   (probablemente /boot de Fedora)
├─p3  758 GB  btrfs  "fedora"  ← SIN MONTAR, SIN USO
└─p4  190 GB  ext4   /          ← Debian, 35 GB usados (20%)
```

Fedora se queda con el **79% del disco** sin encenderse. Plan acordado, **sin
ejecutar todavía**:

1. Montar p3 en **solo lectura** y rescatar lo que valga (documentos,
   proyectos, `~/.ssh`, configs).
2. Respaldar eso fuera del disco. **No saltarse este paso.**
3. Verificar quién controla el arranque (`efibootmgr -v`): si el GRUB activo es
   el de Fedora, resolverlo **antes** de borrar nada.
4. Borrar p3 y p2, crear una partición nueva en el hueco (~758 GB) y montarla
   como `/datos` (o `/home`). **Fedora está *antes* que Debian en el disco**:
   borrarla no agranda p4 automáticamente, y estirarla hacia atrás exige mover
   190 GB (lento y arriesgado). Crear partición nueva es lo seguro.

> Si la instalación limpia se hace desde cero con el instalador de Debian,
> este es el momento de: reparticionar con calma, **activar cifrado LUKS**, y
> dejar la contraseña de root **vacía** (si no, no se instala `sudo`).

## 9. Cómo continuar tras una instalación limpia

```bash
sudo apt install -y git gh
gh auth login                                    # el repo es privado
gh repo clone AngheloBR/dotfiles-debian-crimson ~/.dotfiles
cd ~/.dotfiles
./instalar-paquetes.sh    # apt + Mozilla + nerd fonts + nvim + piper + firewall + lightdm
./instalador.sh           # stow (detecta VM vs hardware real)
sudo reboot
```

Comandos del día a día:

| Para | Comando |
|---|---|
| Validar antes de commitear | `./comprobar.sh` (debe decir TODO OK) |
| Tras un `git pull` con archivos nuevos | `./instalador.sh` (stow -R re-enlaza) |
| Recargar atajos | `pkill -USR1 -x sxhkd` |
| Recargar barra | `polybar-msg cmd restart` |
| Monitores | `~/.local/bin/ajustar-monitores.sh` (o F9) |
| Si el firewall deja sin red | escudo de la barra → APAGAR, o `sudo firewall-perfil apagar` |

## 10. Lecciones aprendidas

Las **28 lecciones técnicas** están en `GUIA-RICE-DEBIAN-BSPWM.txt` §7. Las que
más han mordido:

- **lightdm arranca bspwm con un PATH sin `~/.local/bin`**: por eso hay que
  exportarlo en `bspwmrc` (tuvo a polybar sin arrancar).
- **`pkill -f` / `pgrep -f` buscan en la línea de comando completa**, incluida
  la de la shell que los ejecuta: se suicidan. Usar patrones anclados.
- **`flush ruleset` en nftables borra la tabla de libvirt** y deja a las VMs sin
  red. Usar `flush table inet filter`.
- **En X11, Shift+Tab es `ISO_Left_Tab`**, no Tab con shift.
- **Los iconos del plano 15 (Material) sobreviven al copiar; los del BMP no.**
- **No usar `flock` alrededor de algo que arranca demonios**: el hijo hereda el
  descriptor y deja el candado cogido para siempre.
- **El hook `Stop` de Claude Code salta antes de que se escriba el transcript**:
  hay que esperar a que el archivo deje de crecer.

## 11. Cómo trabajar en este repo

1. Cambiar el archivo en `~/.dotfiles` (afecta al sistema en vivo).
2. Probar de verdad (recargar el programa, mirar el resultado, capturar si hace falta).
3. `./comprobar.sh` → TODO OK.
4. Commit **en español**, descriptivo, explicando el **porqué**; push directo.
5. Si hubo una lección, anotarla en `GUIA-RICE-DEBIAN-BSPWM.txt` §7.
6. Si cambió algo de este contexto, actualizar **este archivo**.
