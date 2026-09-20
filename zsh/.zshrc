# Powerlevel10k instant prompt (carga rapida)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Historial
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Autocompletado. compinit escanea todas las funciones de completado en
# cada terminal nueva (lento). Con -C usa el dump ya generado
# (~/.zcompdump); solo se regenera entero si el dump tiene mas de un dia.
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Plugins
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Powerlevel10k
source ~/.powerlevel10k/powerlevel10k.zsh-theme

# Config de p10k (se genera con el wizard)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# binarios propios (~/.local/bin: scripts del rice, nvim 0.12) y opencode
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

# fzf (busqueda difusa): Ctrl+R historial, Ctrl+T archivos, Alt+C carpetas
# Los archivos los da fd (paquete fd-find, binario "fdfind" en Debian):
# respeta .gitignore y salta node_modules, .git, etc.
if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
  command -v fdfind >/dev/null && export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fdfind --type d --hidden --exclude .git'
  # paleta de la casa: seleccion carmesi, resaltado dorado, fondo del rice
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border=rounded \
    --color=bg+:#2b2b2e,fg+:#e6e6ea,hl:#E8B04B,hl+:#E8B04B \
    --color=border:#D70A53,prompt:#D70A53,pointer:#D70A53,marker:#E8B04B,info:#45474e,spinner:#E8B04B"
fi
