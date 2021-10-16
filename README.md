# dotfiles

```
git clone https://github.com/rakiyoshi/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
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
- Requirement for [vim-syntastic/syntastic](https://github.com/vim-syntastic/syntastic)
    - rubocop
    - yamllint
    - pyflakes
    - pep8

## homeshick
[andsens/homeshick](https://github.com/andsens/homeshick)

## asdf
[asdf-vm/asdf](https://github.com/asdf-vm/asdf)

## aws-sso-util
Set up profile

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
