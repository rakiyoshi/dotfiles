#!/bin/bash

cd ${HOME}

# homeshick
git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
printf '\nsource "$HOME/.homesick/repos/homeshick/homeshick.sh"' >> $HOME/.bashrc
source .bashrc

# homeshick castles
homeshick clone rakiyoshi/vim-castle
homeshick clone rakiyoshi/asdf-castle

# asdf
asdf plugin-add go
asdf plugin-add nodejs
asdf plugin-add python
asdf plugin-add ruby
asdf plugin-add terraform

# git
ln -s ~/.dotfiles/gitconfig .gitconfig
ln -s ~/.dotfiles/gitignore_global .gitignore_global

# zsh
ln -s ~/.dotfiles/zshrc .zshrc
