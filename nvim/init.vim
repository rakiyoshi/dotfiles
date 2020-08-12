if !&compatible
  set nocompatible
endif

"----------------------------------------------------------------------
" Dein設定
"----------------------------------------------------------------------

" Dein
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vimが存在していない場合はgithubからclone
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  let s:toml_dir = expand('~/.config/nvim')
  call dein#load_toml(s:toml_dir . '/dein.toml', {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/dein_lazy.toml', {'lazy': 1})
  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

" 自動削除
let g:dein#auto_recache = 1

""----------------------------------------------------------------------
"" 基本設定
""----------------------------------------------------------------------

" タブをスペースで
set smarttab
set expandtab
set tabstop=4
set smartindent
set shiftwidth=4

" Indent設定
autocmd FileType yaml setlocal ts=2 sts=2 sw=2
autocmd FileType sh setlocal ts=2 sts=2 sw=2
autocmd FileType ruby setlocal ts=2 sts=2 sw=2
autocmd FileType zsh setlocal ts=2 sts=2 sw=2
autocmd FileType tf setlocal ts=2 sts=2 sw=2
autocmd FileType vim setlocal ts=2 sts=2 sw=2
autocmd FileType typescript setlocal ts=2 sts=2 sw=2
autocmd FileType markdown setlocal ts=2 sts=2 sw=2

" 行番号を表示
set number

" Encoding
set encoding=utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis

" Splitの方向
set splitright
set splitbelow

" Undo永続化
if has('persistent_undo')
  set undodir=~/.vim/undo
  set undofile
endif

" Clipboard (mac)
if system('uname') == "Darwin\n"
  set clipboard=unnamed
endif

" JSONのダブルクォーテーションを隠さない
set conceallevel=0

" Terminal modeのショートカット変更
tnoremap <silent> <ESC> <C-\><C-n>

" ローカル設定を読み込み
if filereadable(expand('~/.vimrc_local'))
  source ~/.vimrc_local
endif
if filereadable(expand('./.vimrc_local'))
  source ./.vimrc_local
endif
