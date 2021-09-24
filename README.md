# dotfiles

```
git clone https://github.com/rakiyoshi/dotfiles.git ~/.dotfiles
ln -s .dotfiles/.zshrc ~/.zshrc
```

## neovim
- [Installing Neovim](https://github.com/neovim/neovim/wiki/Installing-Neovim)
- [Shougo/dein.vim](https://github.com/Shougo/dein.vim)
	- ag([ggreer/the_silver_searcher](https://github.com/ggreer/the_silver_searcher))

```bash
./install.sh
# nvim-typescript
cd ~/.cache/dein/repos/github.com/mhartington/nvim-typescript
./install.sh
```
- [vim-syntastic/syntastic](https://github.com/vim-syntastic/syntastic)
    - rubocop
    - yamllint
    - pyflakes
    - pep8

## zsh
- [sorin-ionescu/prezto](https://github.com/sorin-ionescu/prezto)

## python
- [pyenv/pyenv](https://github.com/pyenv/pyenv)

## ruby
- [rbenv/rbenv](https://github.com/rbenv/rbenv)

## terraform
- [tfutils/tfenv](https://github.com/tfutils/tfenv)

## aws-sso-util

```bash
SSO_START_URL=
SSO_REGION=
aws-sso-util configure populate \
  --sso-start-url ${SSO_START_URL} \
  --sso-region ${SSO_REGION} \
  --region ap-northeast-1 \
  --config-default output=yaml \
  --raw-account-names \
  --profile-name-process ${HOME}/.dotfiles/aws-sso-util/profile_formatter.py
```
