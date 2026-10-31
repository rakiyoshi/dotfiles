[[ -o interactive ]] || return
source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/environment.zsh"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE
setopt AUTO_CD INTERACTIVE_COMMENTS
bindkey -e
bindkey '^U' backward-kill-line
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history

autoload -Uz compinit colors vcs_info
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
# Docker Desktop's completion link can dangle while its WSL distro is stopped.
# A valid earlier definition lets compinit skip that broken system entry.
if [[ -L /usr/share/zsh/vendor-completions/_docker && ! -e /usr/share/zsh/vendor-completions/_docker ]]; then
  fpath=("${XDG_CONFIG_HOME:-$HOME/.config}/zsh/completions" $fpath)
fi
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
colors
zstyle ':completion:*' menu select
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
setopt PROMPT_SUBST
autoload -Uz add-zsh-hook
add-zsh-hook precmd vcs_info
PROMPT='%F{green}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_} %# '
RPROMPT='%D{%Y-%m-%d %H:%M:%S}'

alias l='ls'
alias ll='ls -l'
alias la='ls -la'
alias al='ls -la'
alias cp='cp -i'
(( $+commands[nvim] )) && alias vim='nvim'

# mise owns runtime selection. Do not initialize asdf or rbenv here.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

if [[ -t 0 ]]; then
  export GPG_TTY="$(tty)"
fi
if [[ "$(uname -r)" == *[Mm]icrosoft* ]]; then
  umask 022
  if [[ "${DOTFILES_SSH_AGENT_RELAY:-1}" == 1 ]] && (( $+commands[socat] && $+commands[npiperelay.exe] && $+commands[wsl-ssh-agent] )); then
    export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
    wsl-ssh-agent
  fi
fi

[[ -r "$HOME/.google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/.google-cloud-sdk/completion.zsh.inc"
[[ -r "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"

# Machine-specific settings stay outside Git; accept the previous spelling too.
[[ -r "$HOME/.zshrc_local" ]] && source "$HOME/.zshrc_local"
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
return 0
