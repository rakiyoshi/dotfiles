#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# color
autoload -Uz colors
colors

# complete
autoload -Uz compinit
compinit

# alias
alias ll="ls -l"
alias la="ls -la"
alias l="ls -CF"

# history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# PATH
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Charset
export LESSCHARSET=utf-8

# local
load_if_exists() {
    if [ -e $1 ]; then
        source $1
    fi
}
load_if_exists ~/.zshrc_local

# key-bind
bindkey \^U backward-kill-line

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# PROMPT
prompt steeef
