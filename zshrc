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
alias vim="nvim"

# history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

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

# PROMPT
prompt steeef

# WSL
if [ $(uname -r | grep -i 'microsoft') ]; then
  umask 022
fi

# awscli v2
if [ -e /usr/local/bin/aws_completer ]; then
  autoload bashcompinit && bashcompinit
  complete -C '/usr/local/bin/aws_completer' aws
fi

# snap
export PATH="/snap/bin:$PATH"

# The next line enables shell command completion for gcloud.
if [ -f "${HOME}/.google-cloud-sdk/completion.zsh.inc" ]; then . "${HOME}/.google-cloud-sdk/completion.zsh.inc"; fi

# History Ignore
HISTORY_IGNORE="(ls|cd|rm|git|rmdir|mv|cp|export|exit)"

# iTerm2
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# golang
mkdir -p ${HOME}/.go
export GOPATH=${HOME}/.go
export PATH=${PATH}:${GOPATH}/bin

# gpgkey
export GPG_TTY=$(tty)

# pipx
export PATH="$PATH:${HOME}/.local/bin"

# homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
fpath=($HOME/.homesick/repos/homeshick/completions $fpath)

# deno
export DENO_INSTALL="${HOME}/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# asdf
source ${HOME}/.asdf/asdf.sh
# append completions to fpath
fpath=(${HOME}/.asdf/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit
# direnv
eval "$(direnv hook zsh)"
source <(kubectl completion zsh)
