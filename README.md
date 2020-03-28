# dotfiles

```
git clone https://github.com/rakiyoshi/dotfiles.git ~/.dotfiles
ln -s .dotfiles/.zshrc ~/.zshrc
```

## neovim
- [Installing Neovim](https://github.com/neovim/neovim/wiki/Installing-Neovim)
- [Shougo/dein.vim](https://github.com/Shougo/dein.vim)

```bash:install.sh
#!/bin/bash

mkdir -p .config
cd .config
ln -s ~/.dotfiles/.nvim/ nvim
```

## zsh
- [sorin-ionescu/prezto](https://github.com/sorin-ionescu/prezto)

## python
- [pyenv/pyenv](https://github.com/pyenv/pyenv)

## ruby
- [rbenv/rbenv](https://github.com/rbenv/rbenv)

## terraform
- [tfutils/tfenv](https://github.com/tfutils/tfenv)
