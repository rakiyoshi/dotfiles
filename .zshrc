# color
autoload -Uz colors
colors
PROMPT="%{${fg[green]}%}%n@%m%{${reset_color}%}%% "

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
