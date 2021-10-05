#!/bin/bash

cd ${HOME}

git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
printf '\nsource "$HOME/.homesick/repos/homeshick/homeshick.sh"' >> $HOME/.bashrc
source .bashrc

# nvim
homeshick clone rakiyoshi/vim-castle

# env
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
curl -sfL https://direnv.net/install.sh | bash

# git
ln -s ~/.dotfiles/gitconfig .gitconfig
ln -s ~/.dotfiles/gitignore_global .gitignore_global

# zsh
ln -s ~/.dotfiles/zshrc .zshrc
