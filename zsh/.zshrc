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
