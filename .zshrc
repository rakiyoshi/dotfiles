# color
autoload -Uz colors
colors
PROMPT="%{${fg[green]}%}%n%{${reset_color}%}%% "

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

# local
source .zshrc_local
