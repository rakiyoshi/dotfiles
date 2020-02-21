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

# pyenv
if [ -e ${HOME}/.pyenv ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

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

# rbenv
if [ -e ${HOME}/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# PROMPT
prompt steeef

# WSL
if [ $(uname -r | grep -i 'microsoft') ]; then
  umask 022
fi

# awscli v2
source /usr/local/bin/aws_zsh_completer.sh

# snap
export PATH="/snap/bin:$PATH"

# tfenv
export PATH="$HOME/.tfenv/bin:$PATH"
